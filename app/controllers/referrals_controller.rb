class ReferralsController < ApplicationController
  before_filter :enabled?
  before_filter :require_user
  
  def index
    redirect_to new_referral_path
  end
  
  def new
    @referral = Referral.new(:referrer => current_user) if signed_in?
  end

  def create
    params[:referral][:email_list].split().each do |email|
      Referral.create(:email_address => email, :email_text => params[:referral][:email_text], :referrer => current_user)
    end
    flash[:notice] = "Your emails have been sent."
    redirect_to root_url
  end
  
  protected
  
  def enabled?
    @site.referrals ? true : (render :file => "public/404.html", :status => 404)
  end

end
