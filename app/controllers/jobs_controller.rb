class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: %i[show edit update destroy freelancer_complete approve_completion reject_completion]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @jobs = policy_scope(Job).order(created_at: :desc)
    authorize @jobs
  end

  def show
    @job = Job.find(params[:id])
    authorize @job
    if current_user&.freelancer?
      @already_applied = @job.proposals.exists?(user_id: current_user.id)
      @user_proposal = @job.proposals.find_by(user_id: current_user.id) if @already_applied
    end
  end

  def new
    @job = current_user.jobs.new
    authorize @job
  end

  def edit
    authorize @job
  end

  def create
    @job = current_user.jobs.new(job_params)
    authorize @job

    respond_to do |format|
      if @job.save
        format.html { redirect_to @job, notice: "Job was successfully created." }
        format.json { render :show, status: :created, location: @job }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @job

    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: "Job was successfully updated." }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @job
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url, notice: "Job was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def client_accepted_jobs
    # First authorize that the user can access this action
    authorize Job, :client_accepted?
    
    # Then fetch the jobs with policy scope
    @jobs = policy_scope(Job)
             .where(user: current_user)
             .joins(:proposals)
             .where(proposals: { status: 'accepted' })
             .distinct
             .includes(:proposals, :user)
    
  rescue Pundit::NotAuthorizedError
    redirect_to jobs_path, alert: "You don't have permission to view this page"
  rescue ActiveRecord::RecordNotFound
    redirect_to jobs_path, alert: "No jobs found"
  end

  def freelancer_accepted_jobs
    @jobs = if current_user.client?
              current_user.jobs
            else
              Job.joins(:proposals)
                 .where(proposals: { user_id: current_user.id, status: 'accepted' })
            end.includes(:user, :proposals)
    authorize :job, :my_jobs?
  end

  def freelancer_complete
    authorize @job, :freelancer_complete?

    if @job.can_freelancer_complete?(current_user)
      @job.update(status: :freelancer_completed)
      redirect_to freelancer_accepted_jobs_path, notice: 'Job marked as completed by freelancer. Waiting for client confirmation.'
    else
      redirect_to freelancer_accepted_jobs_path, alert: 'You cannot mark this job as completed.'
    end
  end

  def approve_completion
    @job = Job.find(params[:id])
    authorize @job, :approve_completion?
    
    if @job.freelancer_completed?
      @job.update!(status: :completed) # Using ! to raise exception on failure
      release_payment(@job)
      flash[:notice] = 'Job approved!' # Set flash before redirect
      redirect_to client_accepted_jobs_path
    else
      flash[:alert] = 'Invalid state'
      redirect_to client_accepted_jobs_path
    end
  end

def reject_completion
  @job = Job.find(params[:id])
  authorize @job, :reject_completion?
  
  if @job.freelancer_completed?
    @job.update(status: :closed)
    flash[:notice] = 'Completion rejected! freelancer notified... ' # Set flash before redirect
    redirect_to client_accepted_jobs_path
  else
    flash[:alert] = 'Invalid job state for rejection....'
    redirect_to client_accepted_jobs_path
  end
end

  private

  def set_job
    @job = Job.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Job not found or you don't have permission to access it"
    redirect_to jobs_path
  end

  def job_params
    params.require(:job).permit(:title, :description, :budget, :category_id, :complexity, skills: [])
  end

  def release_payment(job)
    job.accepted_proposal&.then do |p|
      p.user.increment!(:balance, p.offer_amount * 0.8)
      p.update!(hold_amount: 0)
    end
  end

end