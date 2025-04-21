class ProposalPolicy
  attr_reader :user, :proposal

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @proposal = record.is_a?(Class) ? nil : record
  end

  # ==== Freelancers ====
  def index?
    user.freelancer? && proposal&.job&.proposals&.exists?(user_id: user.id) == false
  end
  alias_method :create?, :index?

  # ==== Clients ====
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

  # ==== Freelancers ====
  def my_proposals?
    user.freelancer?
  end

  # ==== Policy Scope ====
  class Scope
    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, "must be logged in" unless user
      @user, @scope = user, scope
    end

    def resolve
      return @scope.joins(:job).where(jobs: { user_id: @user.id }) if @user.client?
      return @scope.where(user_id: @user.id) if @user.freelancer?
      @scope.none
    end
  end

  private

  def manage_pending?
    user.client? && proposal&.job&.user == user && proposal&.pending?
  end
end
