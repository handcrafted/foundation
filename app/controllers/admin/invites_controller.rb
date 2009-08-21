class Admin::InvitesController < AdminController
  more_actions Invite, {:approve => "Approve", :destroy => "Delete"}
  
  def index
    @pending_invites = Invite.unused
    @used_invites = Invite.used
  end

  def create
    invite = Invite.new(:email => params[:invite][:email])
    invite.add_inviter(current_user)
    if invite.save
      flash[:notice] = "The invite has been sent."
    else
      flash[:warning] = "The invite wasn't save due to errors."
    end
    respond_to do |format|
      format.html { redirect_to admin_invites_path }
    end
  end

  def edit
  end

  def update
  end

  def destroy
    invite = Invite.find(params[:id])
    invite.destroy
    flash[:notice] = "That invite has been removed."
    respond_to do |format|
      format.html { redirect_to admin_invites_url }
    end
  end

  def approve
    @invite = Invite.find(params[:id])
    @invite.approve!
    @invite.save
    respond_to do |format|
      format.html do
        flash[:notice] = "That beta invite has been approved."
        redirect_to admin_invites_url
      end
      format.js { render :partial => "admin/invites/invite.html.haml", :object => @invite }
    end
  end
  
  def reset
    User.update_all("invites = #{params[:invite][:number]}")
    flash[:notice] = "All user invites have been reset to #{params[:invite][:number]}"
    redirect_to admin_invites_url
  end

end
