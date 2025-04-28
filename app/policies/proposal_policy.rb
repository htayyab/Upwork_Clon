class ProposalPolicy
  attr_reader :user, :proposal

  def initialize(user, proposal)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @proposal = proposal
  end

  # ==== Freelancers ====
  def index?
    user.freelancer? && !proposal&.job&.proposals&.exists?(user_id: user.id)
  end
  alias_method :create?, :index?

  # ==== Clients view all proposls on their jobs====
  def job_proposals?
    user.client? && proposal&.job&.user == user
  end

  def client_proposals?
    user.client?
  end

  def accept?
    manage_pending?
  end
  alias_method :reject? ,:accept?

  # ==== Freelancers view their submitted Proposlas ====
  def my_proposals?
    user.freelancer?
  end
  
  private

  def manage_pending?
    user.client? && proposal&.job&.user == user && proposal&.pending?
  end
  
end
