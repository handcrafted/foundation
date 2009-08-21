class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "You have been signed in."
      redirect_back_or_default account_url
    else
      flash[:warning] = "There is an issue with your credentials."
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "You have been signed out."
    redirect_back_or_default signin_url
  end
end
