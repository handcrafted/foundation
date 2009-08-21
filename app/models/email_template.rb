class EmailTemplate < ActiveRecord::Base
  attr_protected :name
  
  validates_presence_of :name
  validates_presence_of :subject
  validates_presence_of :body
  validates_uniqueness_of :name

  def render_body(options = {})
    render(self.body, options)
  end
  
  def render_subject(options = {})
    render(self.subject, options)
  end
  
  private
  
    def render(text, options)
      Liquid::Template.parse(text).render(options)
    end
  
end
