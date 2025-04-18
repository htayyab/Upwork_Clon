class ProposalPolicy
  attr_reader :user, :proposal

  def initialize(user, proposal)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @proposal = proposal.is_a?(Class) ? nil : proposal
  end

  # =============== Actions for Freelancers ===============
  def index?
    user.freelancer? && !job_has_proposal?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  # =============== Actions for Clients ===============
  def job_proposals?
    user.client? && proposal&.job&.user == user
  end

  def client_proposals?
    user.client?
  end

  def accept?
    can_manage_pending_proposal?
  end

  def reject?
    can_manage_pending_proposal?
  end

  def my_proposals?
    user.freelancer?
  end

  # =============== Policy Scope ===============
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, "must be logged in" unless user
      @user = user
      @scope = scope
    end

    def resolve
      if user.client?
        scope.joins(:job).where(jobs: { user_id: user.id })
      elsif user.freelancer?
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end

  private

  

  def job_has_proposal?
    proposal.present? && proposal.job.proposals.exists?(user_id: user.id)
  end

  def can_manage_pending_proposal?
    user.client? && proposal.present? &&
      proposal.job.present? &&
      proposal.job.user == user &&
      proposal.pending?
  end
end