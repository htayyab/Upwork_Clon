class JobPolicy < ApplicationPolicy
  attr_reader :user, :job

  def initialize(user, job)
    @user = user
    @job = job
  end

  def show?
    !job.archived?
  end

  def create?
    user&.client?
  end
  alias_method :new?, :create?

  def edit?
    user&.client? && owner?
  end
  alias_method :update?, :edit?
  alias_method :destroy?, :edit?

  def index?
    user&.freelancer? || user&.client?
  end

  def my_jobs?
    user&.freelancer?
  end

  def freelancer_complete?
    job.can_freelancer_complete?(user)
  end

  def approve_completion?
    client_owner? && job.freelancer_completed?
  end
  alias_method :reject_completion?, :approve_completion?

  def client_accepted?
    user&.client?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      if user.client?
        # Client can see all their jobs except archived
        scope.where(user: user).where.not(status: :archived)
      elsif user.freelancer?
        # Freelancers see accepted jobs, even if archived
        scope.joins(:proposals)
             .where(proposals: { user_id: user.id, status: 'accepted' })
             .distinct
      else
        scope.none
      end
    end
  end

  private

  def owner?
    job.user == user
  end

  def client_owner?
    user&.client? && owner?
  end
end
