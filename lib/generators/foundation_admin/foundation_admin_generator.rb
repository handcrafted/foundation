class FoundationAdminGenerator < Rails::Generator::NamedBase
  
  def manifest
    columns = class_name.constantize.column_names
    record do |m|
      m.directory('app/controllers/admin')
      m.directory("app/views/admin/#{plural_name}")
      m.template("controller.rb", "app/controllers/admin/#{plural_name}_controller.rb")
      m.template("views/index.html.haml", "app/views/admin/#{plural_name}/index.html.haml")
      m.template("views/new.html.haml", "app/views/admin/#{plural_name}/new.html.haml", :assigns => {:column_names => columns})
      m.template("views/edit.html.haml", "app/views/admin/#{plural_name}/edit.html.haml", :assigns => {:column_names => columns})
    end
  end
  
end