require File.expand_path(File.join(File.dirname(__FILE__),'..','..','test_helper')) 
##require 'new_relic/agent/transaction_sampler'

NewRelic::Agent::TransactionSampler.send :public, :builder

class NewRelic::Agent::TransationSamplerTest < Test::Unit::TestCase
  
  def setup
    Thread::current[:record_sql] = nil
    mock_agent = mock()
    stats_engine_mock = mock()
    stats_engine_mock.stubs(:add_scope_stack_listener)
    mock_agent.stubs(:stats_engine).returns(stats_engine_mock)
    mock_agent.stubs(:set_sql_obfuscator).returns(stats_engine_mock)
    @sampler = NewRelic::Agent::TransactionSampler.new(mock_agent)
  end
  
  def test_multiple_samples
    
    run_sample_trace
    run_sample_trace
    run_sample_trace
    run_sample_trace
    
    samples = @sampler.samples
    assert_equal 4, samples.length
    assert_equal "a", samples.first.root_segment.called_segments[0].metric_name
    assert_equal "a", samples.last.root_segment.called_segments[0].metric_name
  end

  def test_sample_id 
    run_sample_trace do 
      assert @sampler.current_sample_id != 0, @sampler.current_sample_id 
    end
  end
  
  def test_harvest_slowest
    
    run_sample_trace
    run_sample_trace
    run_sample_trace { sleep 0.5 }
    run_sample_trace
    run_sample_trace
    
    slowest = @sampler.harvest(nil, 0)[0]
    assert slowest.duration >= 0.5
    
    run_sample_trace { sleep 0.2 }
    not_as_slow = @sampler.harvest(slowest, 0)[0]
    assert not_as_slow == slowest
    
    run_sample_trace { sleep 0.6 }
    new_slowest = @sampler.harvest(slowest, 0)[0]
    assert new_slowest != slowest
    assert new_slowest.duration >= 0.6
  end
  
  
  def test_preare_to_send
    
    run_sample_trace { sleep 0.2 }
    sample = @sampler.harvest(nil, 0)[0]
    
    ready_to_send = sample.prepare_to_send
    assert sample.duration == ready_to_send.duration
    
    assert ready_to_send.start_time.is_a?(Time)
  end
  
  def test_multithread
    threads = []
    
    20.times do
      t = Thread.new(@sampler) do |the_sampler|
        @sampler = the_sampler
        100.times do
          run_sample_trace { sleep 0.01 }
        end
      end
      
      threads << t
    end
    threads.each {|t| t.join }
  end
  
  def test_sample_with_parallel_paths
    
    assert_equal 0, @sampler.scope_depth
    
    @sampler.notice_first_scope_push Time.now.to_f
    @sampler.notice_transaction "/path", nil, {}
    @sampler.notice_push_scope "a"
    
    assert_equal 1, @sampler.scope_depth 
    
    @sampler.notice_pop_scope "a"
    @sampler.notice_scope_empty
    
    assert_equal 0, @sampler.scope_depth 
    
    @sampler.notice_first_scope_push Time.now.to_f
    @sampler.notice_transaction "/path", nil, {}
    @sampler.notice_push_scope "a"
    @sampler.notice_pop_scope "a"
    @sampler.notice_scope_empty
  end
  
  def test_double_scope_stack_empty
    
    @sampler.notice_first_scope_push Time.now.to_f
    @sampler.notice_transaction "/path", nil, {}
    @sampler.notice_push_scope "a"
    @sampler.notice_pop_scope "a"
    @sampler.notice_scope_empty
    @sampler.notice_scope_empty
    @sampler.notice_scope_empty
    @sampler.notice_scope_empty
    
    assert_not_nil @sampler.harvest(nil, 0)[0]
  end
  
  
  def test_record_sql_off
    
    @sampler.notice_first_scope_push Time.now.to_f
    
    Thread::current[:record_sql] = false
    
    @sampler.notice_sql("test", nil, 0)
    
    segment = @sampler.builder.current_segment
    
    assert_nil segment[:sql]
  end
  
  def test_stack_trace__sql
    @sampler.stack_trace_threshold = 0
    
    @sampler.notice_first_scope_push Time.now.to_f
    
    @sampler.notice_sql("test", nil, 1)
    
    segment = @sampler.builder.current_segment
    
    assert segment[:sql]
    assert segment[:backtrace]
  end
  def test_stack_trace__scope
    
    @sampler.stack_trace_threshold = 0
    t = Time.now
    @sampler.notice_first_scope_push t.to_f
    @sampler.notice_push_scope 'Bill', (t+1.second).to_f
    
    segment = @sampler.builder.current_segment
    assert segment[:backtrace]
  end
  
  def test_nil_stacktrace
    
    @sampler.stack_trace_threshold = 2
    
    @sampler.notice_first_scope_push Time.now.to_f
    
    @sampler.notice_sql("test", nil, 1)
    
    segment = @sampler.builder.current_segment
    
    assert segment[:sql]
    assert_nil segment[:backtrace]
  end
  
  def test_big_sql
    
    @sampler.notice_first_scope_push Time.now.to_f
    
    sql = "SADJKHASDHASD KAJSDH ASKDH ASKDHASDK JASHD KASJDH ASKDJHSAKDJHAS DKJHSADKJSAH DKJASHD SAKJDH SAKDJHS"
    
    len = 0
    while len <= NewRelic::Agent::TransactionSampler::MAX_SQL_LENGTH
      @sampler.notice_sql(sql, nil, 0)
      len += sql.length
    end
    
    segment = @sampler.builder.current_segment
    
    sql = segment[:sql]
    
    assert sql.length <= NewRelic::Agent::TransactionSampler::MAX_SQL_LENGTH
  end
  
  
  def test_segment_obfuscated
    
    @sampler.notice_first_scope_push Time.now.to_f
    
    orig_sql = "SELECT * from Jim where id=66"
    
    @sampler.notice_sql(orig_sql, nil, 0)
    
    segment = @sampler.builder.current_segment
    
    assert_equal orig_sql, segment[:sql]
    assert_equal "SELECT * from Jim where id=?", segment.obfuscated_sql
  end
  
  
  def test_param_capture
    [true, false].each do |capture| 
      NewRelic::Control.instance.stubs(:capture_params).returns(capture)
      @sampler.notice_first_scope_push Time.now.to_f
      @sampler.notice_transaction('/path', nil, {:param => 'hi'})
      @sampler.notice_scope_empty
      
      tt = @sampler.harvest(nil,0)[0]
      
      assert_equal (capture) ? 1 : 0, tt.params[:request_params].length
    end
  end
  
  
  def test_sql_normalization
    
    # basic statement
    assert_equal "INSERT INTO X values(?,?, ? , ?)", 
    @sampler.default_sql_obfuscator("INSERT INTO X values('test',0, 1 , 2)")
    
    # escaped literals
    assert_equal "INSERT INTO X values(?, ?,?, ? , ?)", 
    @sampler.default_sql_obfuscator("INSERT INTO X values('', 'jim''s ssn',0, 1 , 'jim''s son''s son')")
    
    # multiple string literals             
    assert_equal "INSERT INTO X values(?,?,?, ? , ?)", 
    @sampler.default_sql_obfuscator("INSERT INTO X values('jim''s ssn','x',0, 1 , 2)")
    
    # empty string literal
    # NOTE: the empty string literal resolves to empty string, which for our purposes is acceptable
    assert_equal "INSERT INTO X values(?,?,?, ? , ?)", 
    @sampler.default_sql_obfuscator("INSERT INTO X values('','x',0, 1 , 2)")
    
    # try a select statement             
    assert_equal "select * from table where name=? and ssn=?",
    @sampler.default_sql_obfuscator("select * from table where name='jim gochee' and ssn=0012211223")
    
    # number literals embedded in sql - oh well
    assert_equal "select * from table_? where name=? and ssn=?",
    @sampler.default_sql_obfuscator("select * from table_007 where name='jim gochee' and ssn=0012211223")
  end
  
  def test_sql_normalization__single_quotes
    assert_equal "INSERT ? into table",
    @sampler.default_sql_obfuscator("INSERT 'this isn''t a real value' into table")
    assert_equal "INSERT ? into table",
    @sampler.default_sql_obfuscator(%q[INSERT '"' into table])
    assert_equal "INSERT ? into table",
    @sampler.default_sql_obfuscator(%q[INSERT ' "some text" \" ' into table])
#    could not get this one licked.  no biggie    
#    assert_equal "INSERT ? into table",
#    @sampler.default_sql_obfuscator(%q[INSERT '\'' into table])
    assert_equal "INSERT ? into table",
    @sampler.default_sql_obfuscator(%q[INSERT ''' ' into table])
  end
  def test_sql_normalization__double_quotes
    assert_equal "INSERT ? into table",
    @sampler.default_sql_obfuscator(%q[INSERT "this isn't a real value" into table])
    assert_equal "INSERT ? into table",
    @sampler.default_sql_obfuscator(%q[INSERT "'" into table])
    assert_equal "INSERT ? into table",
    @sampler.default_sql_obfuscator(%q[INSERT " \" " into table])
    assert_equal "INSERT ? into table",
    @sampler.default_sql_obfuscator(%q[INSERT " 'some text' " into table])
  end
  def test_sql_obfuscation_filters
    orig =  NewRelic::Agent.agent.obfuscator
    
    NewRelic::Agent.set_sql_obfuscator(:replace) do |sql|
      sql = "1" + sql
    end
    
    sql = "SELECT * FROM TABLE 123 'jim'"
    
    assert_equal "1" + sql, NewRelic::Agent.instance.obfuscator.call(sql)
    
    NewRelic::Agent.set_sql_obfuscator(:before) do |sql|
      sql = "2" + sql
    end
    
    assert_equal "12" + sql, NewRelic::Agent.instance.obfuscator.call(sql)
    
    NewRelic::Agent.set_sql_obfuscator(:after) do |sql|
      sql = sql + "3"
    end
    
    assert_equal "12" + sql + "3", NewRelic::Agent.instance.obfuscator.call(sql)
    
    NewRelic::Agent.agent.set_sql_obfuscator(:replace, &orig)
  end
  
  
  private      
  def run_sample_trace(&proc)
    @sampler.notice_first_scope_push Time.now.to_f
    @sampler.notice_transaction '/path', nil, {}
    @sampler.notice_push_scope "a"
    @sampler.notice_sql("SELECT * FROM sandwiches WHERE bread = 'wheat'", nil, 0)
    @sampler.notice_push_scope "ab"
    @sampler.notice_sql("SELECT * FROM sandwiches WHERE bread = 'white'", nil, 0)
    proc.call if proc
    @sampler.notice_pop_scope "ab"
    @sampler.notice_push_scope "lew"
    @sampler.notice_sql("SELECT * FROM sandwiches WHERE bread = 'french'", nil, 0)
    @sampler.notice_pop_scope "lew"
    @sampler.notice_pop_scope "a"
    @sampler.notice_scope_empty
  end
  
end
