class Mailer < ActionMailer::Base
  
  def self.inherited_without_helper(subclass)
    @@subclasses ||= []
    @@subclasses << subclass
  end
  
  def self.subclasses
    @@subclasses
  end
  
  def self.available_templates
    @@subclasses.collect do |klass|
      klass.instance_methods(false)
    end.flatten
  end
  
  def setup_template(name, email)
    site = SiteSetting.find(:first)
    from site.admin_email.to_s
    reply_to site.admin_email.to_s
    self.mailer_name = 'shared'
    self.template = 'email.html.erb'
    self.template_root = "#{RAILS_ROOT}/app/views"

    options = { 'site' => site }
    yield options if block_given?

    email_template = EmailTemplate.find_by_name(name)
    
    recipients "#{email}"
    
    sent_on Time.now
    subject "[#{site.name}] #{email_template.render_subject(options)}"
    body :content => email_template.render_body(options)
  end
end