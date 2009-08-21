class Admin::EmailsController < AdminController

  def index
    @emails = EmailTemplate.find(:all)
  end
  
  def edit
    @email = EmailTemplate.find(params[:id])
  end
  
  def update
    @email = EmailTemplate.find(params[:id])

    if @email.update_attributes(params[:email_template])
      flash[:notice] = "Successfully updated email template"
      redirect_to admin_emails_url
    else
      flash[:error] = "Unable to update email template"
      render :action => 'edit'
    end
  end
  
  def show
    @email = EmailTemplate.find(params[:id])
  end

end
