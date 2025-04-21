class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: %i[show edit update destroy freelancer_complete approve_completion reject_completion]
  before_action :authorize_job, only: %i[ show edit update destroy]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @jobs = policy_scope(Job).order(created_at: :desc)
    authorize @jobs
  end

  def show
    if current_user&.freelancer?
      @already_applied = @job.applied_by?(current_user)
      @user_proposal = @job.user_proposal(current_user) if @already_applied
    end
  end

  def new
    @job = current_user.jobs.new
    authorize @job
  end

  def edit
  end

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
    @job.destroy
    redirect_to jobs_url, notice: "Job was successfully destroyed."
  end

  def client_accepted_jobs
    authorize Job, :client_accepted?
    @jobs = Job.client_accepted_by(current_user)
  end
  
  def freelancer_accepted_jobs
    authorize :job, :my_jobs?
    @jobs = Job.freelancer_accepted_for(current_user)
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
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Job not found or you don't have permission to access it"
    redirect_to jobs_path
  end

  def job_params
    params.require(:job).permit(:title, :description, :budget, :category_id, :complexity, skills: [])
  end
end
