class Admin::JobsController < AdminController
  more_actions Delayed::Job, {:destroy => "Delete"}

  def index
    @jobs = Delayed::Job.find(:all)
  end

  def show
    @job = Delayed::Job.find(params[:id])
  end

  def destroy
    @job = Delayed::Job.find(params[:id])
    @job.destroy ? flash[:notice] = "The job has been deleted" : flash[:warning] = "There was an issue deleting the job"
    respond_to do |format|
      format.html { redirect_to admin_jobs_url }
    end
  end
  
  def purge_queue
    Delayed::Job.delete_all
    respond_to do |format|
      format.html { redirect_to admin_jobs_url }
      format.js { render :partial => "jobs", :layout => false }
    end
    
  end

end
