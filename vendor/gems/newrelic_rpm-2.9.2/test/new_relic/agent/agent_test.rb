require File.expand_path(File.join(File.dirname(__FILE__),'..','..','test_helper'))
##require 'new_relic/agent/agent'
##require 'new_relic/local_environment'

class AgentTest < ActiveSupport::TestCase
  
  attr_reader :agent
  
  # Fake out the agent to think mongrel is running
  def setup
    NewRelic::Agent.manual_start
    @agent = NewRelic::Agent.instance
  end
  def teardown
    NewRelic::Control.instance['app_name']=nil
    NewRelic::Control.instance['dispatcher']=nil
    NewRelic::Control.instance['dispatcher_instance_id']=nil
  end
  def test_agent_setup
    assert NewRelic::Agent.instance.class == NewRelic::Agent::Agent
    assert_raise RuntimeError do
      NewRelic::Control.instance.init_plugin :agent_enabled => false
    end
  end
  
  def test_public_apis
    assert_raise RuntimeError do
      NewRelic::Agent.set_sql_obfuscator(:unknown) do |sql|
        puts sql
      end
    end
    
    ignore_called = false
    NewRelic::Agent.ignore_error_filter do |e|
      ignore_called = true
      nil
    end
    
    NewRelic::Agent.agent.error_collector.notice_error(ActionController::RoutingError.new("message"), nil, "path", {:x => "y"} )
    
    assert ignore_called    
  end
  
  def test_startup_shutdown
    @agent = NewRelic::Agent::ShimAgent.instance
    @agent.shutdown
    assert (not @agent.started?)
    @agent.start 
    assert !@agent.started?
    # this installs the real agent:
    NewRelic::Agent.manual_start
    @agent = NewRelic::Agent.instance
    assert @agent != NewRelic::Agent::ShimAgent.instance
    assert @agent.started?
    @agent.shutdown
    assert !@agent.started?
    @agent.start
    assert @agent.started?
  end
  
  def test_manual_overrides
    NewRelic::Agent.manual_start :app_name => "testjobs", :dispatcher_instance_id => "mailer"
    assert_equal "testjobs", NewRelic::Control.instance.app_names[0]
    assert_equal "mailer", NewRelic::Control.instance.dispatcher_instance_id
  end
  def test_restart
    NewRelic::Agent.manual_start :app_name => "noapp", :dispatcher_instance_id => ""
    NewRelic::Agent.manual_start :app_name => "testjobs", :dispatcher_instance_id => "mailer"
    assert_equal "testjobs", NewRelic::Control.instance.app_names[0]
    assert_equal "mailer", NewRelic::Control.instance.dispatcher_instance_id
  end
  
  def test_version
    assert_match /\d\.\d\.\d+/, NewRelic::VERSION::STRING
  end
  
  def test_invoke_remote__ignore_non_200_results
    NewRelic::Agent::Agent.class_eval do
      public :invoke_remote
    end
    response_mock = mock()
    Net::HTTP.any_instance.stubs(:request).returns(response_mock)
    response_mock.stubs(:message).returns("bogus error")
    
    for code in %w[500 504 400 302 503] do 
      assert_raise NewRelic::Agent::IgnoreSilentlyException, "Ignore #{code}" do
        response_mock.stubs(:code).returns(code)
        NewRelic::Agent.agent.invoke_remote  :get_data_report_period, 0
      end
    end
  end
  def test_invoke_remote__throw_other_errors
    NewRelic::Agent::Agent.class_eval do
      public :invoke_remote
    end
    response_mock = Net::HTTPSuccess.new  nil, nil, nil
    response_mock.stubs(:body).returns("")
    Marshal.stubs(:load).raises(RuntimeError, "marshal issue")
    Net::HTTP.any_instance.stubs(:request).returns(response_mock)
    assert_raise RuntimeError do
      NewRelic::Agent.agent.invoke_remote  :get_data_report_period, 0xFEFE
    end
  end
end