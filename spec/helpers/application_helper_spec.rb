require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  include ApplicationHelper
  
  describe 'page title' do

    it "should use backwards title if flipped" do
      @flipped = true
      self.should_receive(:backwards_title).and_return("hello")
      page_title.should == "hello"
    end
    
    it "should use partial title if not flipped" do
      self.should_receive(:partial_title).and_return("boom")
      page_title.should == "boom"
    end

    it "should use @full_title variable if partial title not set" do
      self.should_receive(:partial_title).and_return(nil)
      @full_title = "world"
      page_title.should == "world"
    end
    
    it "should use forwards title if none available so far" do
      self.should_receive(:partial_title).and_return(nil)
      self.should_receive(:forwards_title).and_return('yay')
      page_title.should == "yay"
    end
  end
  
  describe "backwards title" do
    before do
      @title_item = "title"
      @controller_name = 'MightyController'
      @site = mock_model(SiteSetting)
      @site.should_receive(:name).and_return('daily news')
    end
    
    it "should include title item" do
      backwards_title.should == "title - MightyController - daily news"
    end
    
    it "should work without title item" do
      @title_item = nil
      backwards_title.should == "MightyController - daily news"
    end
    
    it "should use @controller_name variable" do
      backwards_title.should == "title - MightyController - daily news"
    end
    
    it "should call controller_name() when @controller_name is not set" do
      @controller_name = nil
      name = mock_model(String)
      self.should_receive(:controller_name).and_return(name)
      name.should_receive(:capitalize).and_return("StockController")
      backwards_title.should == "title - StockController - daily news"
    end
  end
  
  describe "forwards title" do
    before do
      @site = mock_model(SiteSetting)
      @site.should_receive(:name).and_return('fast forward')
      @controller_name = 'SongController'
      @title_item = "rush"
    end

    it "should use @controller_name variable" do
      forwards_title.should == "fast forward - SongController - rush"
    end
    
    it "should call controller_name() when @controller_name is not set" do
      @controller_name = nil
      name = mock_model(String)
      self.should_receive(:controller_name).and_return(name)
      name.should_receive(:capitalize).and_return("TvController")
      forwards_title.should == "fast forward - TvController - rush"
    end

    it "should include title item" do
      forwards_title.should == "fast forward - SongController - rush"
    end
    
    it "should work without title item" do
      @title_item = nil
      forwards_title.should == "fast forward - SongController"
    end
  end
  
  describe "partial title" do

    it "should return nil unless @partial_title is set" do
      @partial_title = nil
      partial_title.should be_nil
    end
    
    it "should include @partial_title with site name" do
      @site = mock_model(SiteSetting)
      @site.should_receive(:name).and_return('boot me')
      @partial_title = "gold"
      partial_title.should == "boot me - gold"
    end
  end
  
  describe "miscellaneous" do
    
    before do
      @params = {
        :controller => "Movies",
        :action => "show"
      }
      self.stub!(:params).and_return(@params)
    end
    
    it "should singularize controller name when action is show" do
      controller_name.should == "Movie"
    end
    
    it "should use controller for non-show actions" do
      @params[:action] = 'index'
      controller_name.should == "Movies"
    end
    
    it "should replace slash with underscore" do
      clean_controller_id("abc/xyz/www").should == "abc_xyz_www"
    end
    
    it "should use id if controller is pages" do
      body_class("pages", "home").should == "home"
    end
    
    it "should use controller when it is not pages" do
      body_class("songs", "index").should == "songs"
    end
  end
  
  
end