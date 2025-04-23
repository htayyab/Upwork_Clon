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
    user&.client?
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

  

  private

  def owner?
    job.user == user
  end

  def client_owner?
    user&.client? && owner?
  end
end
