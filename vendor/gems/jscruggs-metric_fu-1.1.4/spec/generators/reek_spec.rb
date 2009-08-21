require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Reek do
  describe "analyze method" do
    before :each do
      MetricFu::Reek.stub!(:verify_dependencies!).and_return(true)
      @lines = <<-HERE
"app/controllers/activity_reports_controller.rb" -- 4 warnings:
ActivityReportsController#authorize_user calls current_user.primary_site_ids multiple times (Duplication)
ActivityReportsController#authorize_user calls params[id] multiple times (Duplication)
ActivityReportsController#authorize_user calls params[primary_site_id] multiple times (Duplication)
ActivityReportsController#authorize_user has approx 6 statements (Long Method)

"app/controllers/application.rb" -- 1 warnings:
ApplicationController#start_background_task/block/block is nested (Nested Iterators)

"app/controllers/link_targets_controller.rb" -- 1 warnings:
LinkTargetsController#authorize_user calls current_user.role multiple times (Duplication)

"app/controllers/newline_controller.rb" -- 1 warnings:
NewlineController#some_method calls current_user.<< "new line\n" multiple times (Duplication)
      HERE
      MetricFu::Configuration.run {}
      File.stub!(:directory?).and_return(true)
      reek = MetricFu::Reek.new
      reek.instance_variable_set(:@output, @lines)
      @matches = reek.analyze
    end
      
    it "should find the code smell's method name" do
      smell = @matches.first[:code_smells].first
      smell[:method].should == "ActivityReportsController#authorize_user"
    end
    
    it "should find the code smell's type" do
      smell = @matches[1][:code_smells].first
      smell[:type].should == "Nested Iterators"
    end
    
    it "should find the code smell's message" do
      smell = @matches[1][:code_smells].first
      smell[:message].should == "is nested"
    end
    
    it "should find the code smell's type" do
      smell = @matches.first
      smell[:file_path].should == "app/controllers/activity_reports_controller.rb"
    end
    
    it "should NOT insert nil smells into the array when there's a newline in the method call" do
      @matches.last[:code_smells].should == @matches.last[:code_smells].compact
      @matches.last.should == {:file_path=>"app/controllers/newline_controller.rb", 
                                :code_smells=>[{:type=>"Duplication", 
                                                  :method=>"\"", 
                                                  :message=>"multiple times"}]}
      # Note: hopefully a temporary solution until I figure out how to deal with newlines in the method call more effectively -Jake 5/11/2009
    end
  end
  
end
