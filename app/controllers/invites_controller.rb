class InvitesController < ApplicationController
  
  #layout "sessions.html.haml"
  
  def new
    @invite = Invite.new
  end

  def create
    @invite = Invite.new(:email => params[:invite][:email], :approved => false)
    @invite.add_inviter(current_user) if signed_in?
    respond_to do |format|
      if @invite.save
        flash[:notice] = "Your invite request has been sent to a site admin." if @invite.unapproved?
        flash[:notice] = "Your invite has been sent" if @invite.approved?
        format.html { redirect_to root_url }
      else
        flash[:warning] = "There was an error with your invite request."
        format.html { render :action => :new }
      end
    end
    
  end

end
