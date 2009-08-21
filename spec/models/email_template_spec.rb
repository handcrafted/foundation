require File.dirname(__FILE__) + '/../spec_helper'

describe EmailTemplate do
  before(:each) do
    @email = Factory.build(:email_template)
  end

  it "should be valid" do
    @email.should be_valid
  end
  
  describe "rendering" do
    it "should render subject with liquid" do
      template = Object.new
      Liquid::Template.should_receive(:parse).with(@email.subject).and_return(template)
      options = { 'abc' => 'www' }
      template.should_receive(:render).with(options)
      
      @email.render_subject(options)
    end
    
    it "should render body with liquid" do
      template = Object.new
      Liquid::Template.should_receive(:parse).with(@email.body).and_return(template)
      options = { 'abc' => 'www' }
      template.should_receive(:render).with(options)
      
      @email.render_body(options)
    end
  end
  
  describe "validations" do
    it "should require name" do
      email = Factory.build(:email_template, :name => nil)
      email.should_not be_valid
      email.should have(1).error_on(:name)
    end
    
    it "should require subject" do
      email = Factory.build(:email_template, :subject => nil)
      email.should_not be_valid
      email.should have(1).error_on(:subject)
    end

    it "should require body" do
      email = Factory.build(:email_template, :body => nil)
      email.should_not be_valid
      email.should have(1).error_on(:body)
    end
    
    it "should not allow duplicate names" do
      email1 = Factory(:email_template)
      email2 = Factory.build(:email_template, :name => email1.name)
      email2.should_not be_valid
      email2.should have(1).error_on(:name)
    end
  end
end
