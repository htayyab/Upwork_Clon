class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: %i[show edit update destroy freelancer_complete approve_completion reject_completion]
  before_action :authorize_job, only: %i[show edit update destroy]
  before_action :prevent_modification_if_in_progress, only: %i[edit update destroy]
  before_action :prevent_editing_if_completed, only: %i[edit update]
  after_action :verify_authorized, except: :index


  def index
    @jobs = Job.all_jobs_excluded_archived(current_user)
    authorize @jobs
  end

  def show
      @already_applied = @job.applied_by?(current_user)
      @user_proposal = @job.user_proposal(current_user) if @already_applied
  end

  def new
    @job = current_user.jobs.new
    authorize @job
  end
  
  def edit; end

  def create
    @job = current_user.jobs.new(job_params)
    authorize @job

    if @job.save
      redirect_to @job, notice: "Job was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @job.update(job_params)
      redirect_to @job, notice: "Job was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @job.update(status: :archived) # ✅ Archive instead of destroy
      redirect_to jobs_url, notice: "Job was archived successfully."
    else
      redirect_to @job, alert: "Failed to archive the job."
    end
  end

  def client_accepted_jobs
    authorize Job, :client_accepted?
    @jobs = Job.accepted_jobs(current_user)
  end

  def freelancer_accepted_jobs
    authorize :job, :my_jobs?
    start_time = Time.now
    @jobs = Job.accepted_jobs(current_user)
    end_time = Time.now
    execution_time_ms = (end_time - start_time) * 1000
    puts "Execution time: #{execution_time_ms.round(2)} ms"
  end

  def freelancer_complete
    authorize @job, :freelancer_complete?

    if @job.mark_as_freelancer_completed_by(current_user)
      redirect_to freelancer_accepted_jobs_path, notice: 'Job marked as completed by freelancer. Waiting for client confirmation.'
    else
      redirect_to freelancer_accepted_jobs_path, alert: 'You cannot mark this job as completed.'
    end
  end

  def approve_completion
    authorize @job, :approve_completion?
    if @job.approve_completion!
      redirect_to client_accepted_jobs_path, notice: 'Job approved!'
    else
      redirect_to client_accepted_jobs_path, alert: 'Invalid state'
    end
  end

  def reject_completion
    authorize @job, :reject_completion?
    if @job.reject_completion!
      redirect_to client_accepted_jobs_path, notice: 'Completion rejected! Freelancer notified.'
    else
      redirect_to client_accepted_jobs_path, alert: 'Invalid job state for rejection.'
    end
  end

  private

  def authorize_job
    authorize @job
  end

  def set_job
    @job = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:title, :description, :budget, :category_id, :complexity, skills: [])
  end

  def prevent_editing_if_completed
    if @job.completed?
      redirect_to @job, alert: "Completed jobs cannot be modified."
    end
  end

  def prevent_modification_if_in_progress
    if @job.proposals.accepted.exists? && !@job.completed?
      redirect_to @job, alert: "You can't modify or delete a job that is currently in progress."
    end
  end
end
