class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:edit, :update]
  before_filter :check_for_public_profiles, :only => :show
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Thank you for signing up"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end
  
  def show
    if params[:id].blank?
      @user = current_user
    else
      @user = User.find(params[:id])
    end
  end

  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your account has been updated"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
  
  private
  
  def check_for_public_profiles
    require_user unless @site.public_profiles?
  end
  
end
