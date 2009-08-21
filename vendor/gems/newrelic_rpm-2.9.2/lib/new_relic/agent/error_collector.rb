
module NewRelic::Agent
  class ErrorCollector
    include CollectionHelper
    
    MAX_ERROR_QUEUE_LENGTH = 20 unless defined? MAX_ERROR_QUEUE_LENGTH
    
    attr_accessor :enabled
    
    def initialize(agent = nil)
      @agent = agent
      @errors = []
      # lookup of exception class names to ignore.  Hash for fast access
      @ignore = {}
      @ignore_filter = nil

      config = NewRelic::Control.instance.fetch('error_collector', {})
      
      @enabled = config.fetch('enabled', true)
      @capture_source = config.fetch('capture_source', true)
      
      ignore_errors = config.fetch('ignore_errors', "")
      ignore_errors = ignore_errors.split(",")
      ignore_errors.each { |error| error.strip! } 
      ignore(ignore_errors)
      @lock = Mutex.new
    end
    
    def ignore_error_filter(&block)
      @ignore_filter = block
    end
    
    
    # errors is an array of Exception Class Names
    #
    def ignore(errors)
      errors.each { |error| @ignore[error] = true; log.debug("Ignoring error: '#{error}'") }
    end
    
    
    def notice_error(exception, request=nil, action_path=nil, filtered_params={})
      
      return unless @enabled
      return if @ignore[exception.class.name] 
      
      if @ignore_filter
        exception = @ignore_filter.call(exception)
        
        return if exception.nil?
      end
      
      error_stat.increment_count
      
      data = {}
      
      action_path ||= ''
      
      data[:request_params] = normalize_params(filtered_params) if NewRelic::Control.instance.capture_params

      data[:custom_params] = normalize_params(@agent.custom_params) if @agent
      
      data[:request_uri] = request.path if request
      data[:request_uri] ||= ""
      
      data[:request_referer] = request.referer if request
      data[:request_referer] ||= ""
      
      data[:rails_root] = NewRelic::Control.instance.root
      
      data[:file_name] = exception.file_name if exception.respond_to?('file_name')
      data[:line_number] = exception.line_number if exception.respond_to?('line_number')
      
      if @capture_source && exception.respond_to?('source_extract')
        data[:source] = exception.source_extract
      end
      
      if exception.respond_to? 'original_exception'
        inside_exception = exception.original_exception
      else
        inside_exception = exception
      end

      data[:stack_trace] = inside_exception.backtrace
      
      noticed_error = NewRelic::NoticedError.new(action_path, data, exception)
      
      @lock.synchronize do
        if @errors.length >= MAX_ERROR_QUEUE_LENGTH
          log.info("The error reporting queue has reached #{MAX_ERROR_QUEUE_LENGTH}. This error will not be reported to RPM: #{exception.message}")
        else
          @errors << noticed_error
        end
      end
    end
    
    # Get the errors currently queued up.  Unsent errors are left 
    # over from a previous unsuccessful attempt to send them to the server.
    # We first clear out all unsent errors before sending the newly queued errors.
    def harvest_errors(unsent_errors)
      if unsent_errors && !unsent_errors.empty?
        return unsent_errors
      else
        @lock.synchronize do
          errors = @errors
          @errors = []
          return errors
        end
      end
    end
    
    private
    def error_stat
      @error_stat ||= NewRelic::Agent.get_stats("Errors/all")
    end
    def log
      NewRelic::Control.instance.log
    end
  end
end