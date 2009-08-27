class Admin::UsersController < AdminController
  before_filter :find_user, :except => [:index]

  def index
    @page = params[:page] || 1
    @users = User.paginate(:all, :page => @page)
    
    respond_to do |format|
      format.html
    end    
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def edit
    
  end

  def update
    respond_to do |format|
      if @user.update_attributes(params[:user]) 
        @user.profile.update_attributes(params[:profile])
        format.html { redirect_to admin_users_url }
      else
        format.html { render :action => :edit }
      end
    end
  end

  private
  
  def find_user
    @user = User.find(params[:id])
  end

end