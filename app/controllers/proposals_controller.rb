class ProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: [:index, :create, :job_proposals]
  before_action :set_proposal, only: [:accept, :reject]
  before_action :authorize_proposal, only: [:accept, :reject]

  def index
    @proposal = @job.proposals.new
    authorize @proposal
  end

  def create
    @proposal = @job.proposals.new(proposal_params.merge(user: current_user))
    authorize @proposal
    if @proposal.save
      redirect_to search_path, notice: 'Proposal submitted successfully!'
    else
      flash.now[:alert] = @proposal.errors.full_messages.to_sentence
      render :index, status: :unprocessable_entity
    end
  end

  def job_proposals
    dummy_proposal = @job.proposals.first || @job.proposals.new
    authorize dummy_proposal, :job_proposals?
    @proposals = policy_scope(@job.proposals).includes(:user)
  end

  def client_proposals
    authorize Proposal, :client_proposals?
    @jobs = current_user.jobs.includes(proposals: :user)
  end

  def my_proposals
    authorize Proposal, :my_proposals?
    @proposals = current_user.proposals.includes(:job)
  end

  def accept
    if @proposal.accept!
      redirect_to client_proposals_proposals_path, notice: 'Proposal accepted successfully!'
    else
      redirect_to client_proposals_proposals_path, alert: 'Only pending proposals can be accepted'
    end
  end

  def reject
    if @proposal.reject!
      redirect_to client_proposals_proposals_path, notice: 'Proposal rejected successfully!'
    else
      redirect_to client_proposals_proposals_path, alert: 'Only pending proposals can be rejected'
    end
  end

  private

  def set_job
    @job = Job.find(params[:job_id])
  end

  def set_proposal
    @proposal = Proposal.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Proposal not found'
  end

  def authorize_proposal
    authorize @proposal, "#{action_name}?".to_sym
  end

  def proposal_params
    params.require(:proposal).permit(
      :offer_amount,
      :cover_letter,
      :estimated_time,
      attachments: []
    )
  end
end
