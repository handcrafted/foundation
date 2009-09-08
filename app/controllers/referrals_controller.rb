class ReferralsController < ApplicationController
  before_filter :enabled?
  
  def index
    redirect_to new_referral_path
  end
  
  def new
    @referral = Referral.new(:referrer => current_user) if signed_in?
  end

  def create
    logger.info params[:referral][:email_list].split().inspect
    redirect_to root_url
  end
  
  protected
  
  def enabled?
    @site.referrals ? true : (render :file => "public/404.html", :status => 404)
  end

end
