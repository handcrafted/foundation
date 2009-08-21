class ReferralsController < ApplicationController
  before_filter :enabled?
  
  # layout "sessions.html.haml"
  
  def index
    redirect_to new_referral_path
  end
  
  def new
    @referrer_profile = current_user.profile if signed_in?
  end

  def create
    referrer = Profile.find_or_create_by_email(:email => params[:referral][:email], :first_name => params[:referral][:first_name], :last_name => params[:referral][:last_name])
    referrer.add_referrals(params[:referral][:friends_email], params[:referral][:email_text])
    redirect_to root_url
  end
  
  protected
  
  def enabled?
    @site.referrals ? true : (render :file => "public/404.html", :status => 404)
  end

end
