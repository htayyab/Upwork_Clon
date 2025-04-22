class ProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: %i[index create ]
  before_action :set_proposal, only: %i[accept reject]
  before_action :authorize_proposal, only: %i[accept reject]

  
  def index
    @proposal = authorize @job.proposals.new
  end

  def create
    @proposal = authorize @job.proposals.new(proposal_params.merge(user: current_user))
    if @proposal.save
      redirect_to search_path, notice: 'Proposal submitted successfully!'
    else
      flash.now[:alert] = @proposal.errors.full_messages.to_sentence
      render :index, status: :unprocessable_entity
    end
  end


  #clients see all proposals on their own specific job 
  def client_proposals
    authorize Proposal, :client_proposals?
    @jobs = current_user.jobs.includes(proposals: :user)
  end

  #freelancers see all proposels they send on all jobs 
  def my_proposals
    authorize Proposal, :my_proposals?
    @proposals = current_user.proposals.includes(:job)
  end

  def accept
    process_decision(@proposal.accept!, 'accepted')
  end

  def reject
    process_decision(@proposal.reject!, 'rejected')
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
    params.require(:proposal).permit(:offer_amount,:cover_letter,:estimated_time,attachments: [])
  end

  def process_decision(success, action)
    path = client_proposals_proposals_path
    notice = success ? "Proposal #{action} successfully!" : "Only pending proposals can be #{action}"
    redirect_to path, (success ? { notice: } : { alert: notice })
  end
end
