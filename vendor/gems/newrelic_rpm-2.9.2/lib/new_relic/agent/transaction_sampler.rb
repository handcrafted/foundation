
module NewRelic::Agent
  
  class TransactionSampler
    
    BUILDER_KEY = :transaction_sample_builder

    attr_accessor :stack_trace_threshold, :random_sampling, :sampling_rate, :last_sample, :samples
    
    def initialize(agent)
      @samples = []
      
      @harvest_count = 0
      @max_samples = 100
      @random_sample = nil
      config = NewRelic::Control.instance
      sampler_config = config.fetch('transaction_tracer', {})
      @stack_trace_threshold = sampler_config.fetch('stack_trace_threshold', 0.500).to_f
      
      agent.stats_engine.add_scope_stack_listener self

      agent.set_sql_obfuscator(:replace) do |sql| 
        default_sql_obfuscator(sql)
      end
      @samples_lock = Mutex.new
    end
    
    def current_sample_id
      b=builder
      b and b.sample_id
    end

    def disable
      NewRelic::Agent.instance.stats_engine.remove_scope_stack_listener self
    end
    
    def sampling_rate=(val)
      @sampling_rate = val
      @harvest_count = rand(val)
    end
    
    def default_sql_obfuscator(sql)
      sql = sql.dup
      # This is hardly readable.  Use the unit tests.
      # remove single quoted strings:
      sql.gsub!(/'(.*?[^\\'])??'(?!')/, '?')
      # remove double quoted strings:
      sql.gsub!(/"(.*?[^\\"])??"(?!")/, '?')
      # replace all number literals
      sql.gsub!(/\d+/, "?")
      sql
    end
    
    
    def notice_first_scope_push(time)
      if Thread::current[:record_tt] == false
        Thread::current[BUILDER_KEY] = nil
      else
        Thread::current[BUILDER_KEY] = TransactionSampleBuilder.new(time)
      end
    end
    
    def notice_push_scope(scope, time=Time.now.to_f)
      
      return unless builder
      
      builder.trace_entry(scope, time)
      
      # in developer mode, capture the stack trace with the segment.
      # this is cpu and memory expensive and therefore should not be
      # turned on in production mode
      if NewRelic::Control.instance.developer_mode?
        segment = builder.current_segment
        if segment
          # Strip stack frames off the top that match /new_relic/agent/
          trace = caller
          while trace.first =~/\/lib\/new_relic\/agent\//
            trace.shift
          end
          
          trace = trace[0..39] if trace.length > 40
          segment[:backtrace] = trace
        end
      end
    end
    
    def scope_depth
      return 0 unless builder

      builder.scope_depth
    end
  
    def notice_pop_scope(scope, time = Time.now.to_f)
      return unless builder
      builder.trace_exit(scope, time)
    end
    
    # This is called when we are done with the transaction.  We've
    # unwound the stack to the top level.
    def notice_scope_empty(time=Time.now.to_f)
      
      last_builder = builder
      return unless last_builder

      last_builder.finish_trace(time)
      reset_builder
    
      @samples_lock.synchronize do
        @last_sample = last_builder.sample
        
        # We sometimes see "unanchored" transaction traces
        if @last_sample.params[:path]
          @random_sample = @last_sample if @random_sampling
                  
          # ensure we don't collect more than a specified number of samples in memory
          @samples << @last_sample if NewRelic::Control.instance.developer_mode?
          @samples.shift while @samples.length > @max_samples
          
          if @slowest_sample.nil? || @slowest_sample.duration < @last_sample.duration
            @slowest_sample = @last_sample
          end
        end
      end
    end
    
    def notice_transaction(path, request, params)
      return unless builder

      builder.set_transaction_info(path, request, params)
    end
    
    def notice_transaction_cpu_time(cpu_time)
      return unless builder

      builder.set_transaction_cpu_time(cpu_time)
    end
    
        
    # some statements (particularly INSERTS with large BLOBS
    # may be very large; we should trim them to a maximum usable length
    # config is the driver configuration for the connection
    MAX_SQL_LENGTH = 16384
    def notice_sql(sql, config, duration)
      return unless builder
      if Thread::current[:record_sql].nil? || Thread::current[:record_sql]
        segment = builder.current_segment
        if segment
          current_sql = segment[:sql]
          sql = current_sql + ";\n" + sql if current_sql

          if sql.length > (MAX_SQL_LENGTH - 4)
            sql = sql[0..MAX_SQL_LENGTH-4] + '...'
          end
          
          segment[:sql] = sql
          segment[:connection_config] = config
          segment[:backtrace] = caller.join("\n") if duration >= @stack_trace_threshold 
        end
      end
    end

    
    # get the set of collected samples, merging into previous samples,
    # and clear the collected sample list. 
    
    def harvest(previous = nil, slow_threshold = 2.0)
      result = []
      previous ||= []
      
      previous = [previous] unless previous.is_a?(Array)
      
      previous_slowest = previous.inject(nil) {|a,ts| (a) ? ((a.duration > ts.duration) ? a : ts) : ts}
      
      @samples_lock.synchronize do
        
        if @random_sampling        
          @harvest_count += 1
          
          if (@harvest_count % @sampling_rate) == 0
            result << @random_sample if @random_sample
            @random_sample = nil
          end
        end
        
        slowest = @slowest_sample
        @slowest_sample = nil
        
        if slowest && slowest != @random_sample && slowest.duration >= slow_threshold
          if previous_slowest.nil? || previous_slowest.duration < slowest.duration
            result << slowest
          else
            result << previous_slowest
          end
        end
      end
      result
    end

    # reset samples without rebooting the web server
    def reset!
      @samples = []
    end

    private 
      
      def builder
        Thread::current[BUILDER_KEY]
      end
      def reset_builder
        Thread::current[BUILDER_KEY] = nil
      end
      
  end

  # a builder is created with every sampled transaction, to dynamically
  # generate the sampled data.  It is a thread-local object, and is not
  # accessed by any other thread so no need for synchronization.
  class TransactionSampleBuilder
    attr_reader :current_segment
    
    include CollectionHelper
    
    def initialize(time=Time.now.to_f)
      @sample = NewRelic::TransactionSample.new(time)
      @sample_start = time
      @current_segment = @sample.root_segment
    end

    def sample_id
      @sample.sample_id
    end

    def trace_entry(metric_name, time)
      segment = @sample.create_segment(time - @sample_start, metric_name)
      @current_segment.add_called_segment(segment)
      @current_segment = segment
    end

    def trace_exit(metric_name, time)
      if metric_name != @current_segment.metric_name
        fail "unbalanced entry/exit: #{metric_name} != #{@current_segment.metric_name}"
      end
      
      @current_segment.end_trace(time - @sample_start)
      @current_segment = @current_segment.parent_segment
    end
    
    def finish_trace(time)
      # This should never get called twice, but in a rare case that we can't reproduce in house it does.
      # log forensics and return gracefully
      if @sample.frozen?
        log = NewRelic::Control.instance.log
        
        log.warn "Unexpected double-freeze of Transaction Trace Object."
        log.info "Please send this diagnostic data to New Relic"
        log.info @sample.to_s
        return
      end
      
      @sample.root_segment.end_trace(time - @sample_start)
      @sample.params[:custom_params] = normalize_params(NewRelic::Agent.instance.custom_params) 
      @sample.freeze
      @current_segment = nil
    end
    
    def scope_depth
      depth = -1        # have to account for the root
      current = @current_segment
      
      while(current)
        depth += 1
        current = current.parent_segment
      end
      
      depth
    end
    
    def freeze
      @sample.freeze unless sample.frozen?
    end
    
    
    def set_transaction_info(path, request, params)
      @sample.params[:path] = path
      
      if NewRelic::Control.instance.capture_params
        params = normalize_params params
        
        @sample.params[:request_params].merge!(params)
        @sample.params[:request_params].delete :controller
        @sample.params[:request_params].delete :action
      end
      
      @sample.params[:uri] = request.path if request
    end
    
    def set_transaction_cpu_time(cpu_time)
      @sample.params[:cpu_time] = cpu_time
    end
    
    
    def sample
      fail "Not finished building" unless @sample.frozen?
      @sample
    end
    
  end
end
