class Admin::ProfilesController < AdminController
  more_actions Profile

  def index
    @profiles = Profile.find(:all)
    respond_to do |format|
      format.html
    end
  end

  def destroy
  end

  def referrals
    
  end

  def subscribers
  end

end
