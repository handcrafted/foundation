module MoreActionsHelper
  
  def resources_table(resources, options = {})
    options.reverse_merge!(default_resource_options)
    render :partial => "resources/table", :locals => {:resources => resources, :options => options}
  end
  
  def option_from_label(action, label)
    case label
    when Array
      label_contents = "<option value=\"#{action}\">#{action.to_s.capitalize}</option>"
    when Hash
      label_contents = "<option value=\"#{action}\" before=\"#{label[:before]}\">#{label[:label]}</option>"
    else
      label_contents = "<option value=\"#{action}\">#{label}</option>"
    end
  end
  
  def resource_id(resource)
    resource.class.to_s.demodulize.underscore + "_" + resource.id.to_s
  end
  
  def default_resource_options
    options = {}
    options[:manage_url] = url_for(:action => "manage")
    options[:headers] = @more_action_columns.collect {|column| column.humanize}
    options[:fields] = @more_action_columns
    options[:default_text] = "No #{@more_actions_model.to_s.downcase.pluralize} were found."
    options[:more_actions] = @more_actions
    options[:link_action] = "show"
    options
  end
  
end