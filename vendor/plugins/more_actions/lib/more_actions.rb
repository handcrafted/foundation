module MoreActions
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    unloadable
    
    def more_actions(model, actions = {})
      @@more_actions_model = model.to_s.camelize.constantize
      
      before_filter :check_allowable_actions, :only => :manage
      before_filter :set_more_actions_list, :only => :index
      before_filter :set_column_list, :only => :index

      define_method(:manage) do
        @resources = @@more_actions_model.send(:find, params[:ids]).to_a.flatten
        @new_resources = @resources.collect {|resource| resource.send(params[:more_action])}
        respond_to do |format|
          format.html { redirect_to :controller => params[:controller], :action => "index" }
          format.json { render :json => @new_resources }
        end
      end

      define_method(:set_more_actions_list) do
        case actions
        when Hash
          @more_actions = actions
        when Array
          @more_actions = actions.to_a.flatten
        else
          @more_actions = actions.to_a.flatten
        end
      end
      
      define_method(:set_column_list) do
        @more_action_columns = @@more_actions_model.send(:column_names)
        @more_actions_model = @@more_actions_model
      end

      define_method(:check_allowable_actions) do
        render :file => "422.html", :status => 422 unless actions.to_a.flatten.include?(params[:more_action].to_sym)
      end
    end
    
  end
  
end