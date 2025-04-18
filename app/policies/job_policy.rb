class JobPolicy < ApplicationPolicy
  attr_reader :user, :job

  def initialize(user, job)
    @user = user
    @job = job
  end

  def show?
    # Anyone can view a job (including guests)
    true
  end

  def create?
    # Only authenticated users with client role can create jobs
    user.present? && user.client?
  end
  alias_method :new?, :create?

  def edit?
    # Only job owner with client role can edit
    user.present? && user.client? && owner?
  end
  alias_method :update?, :edit?
  alias_method :destroy?, :edit?

  def index?
    # Freelancers can view job listings, clients can view their own jobs
    user.present? && (user.freelancer? || user.client?)
  end

  def my_jobs?
    user.freelancer?  # Only freelancers can access their accepted jobs
  end

  def freelancer_complete?
    job.can_freelancer_complete?(user)
  end

  
  
  def approve_completion?
    user.client? && job.user == user && job.freelancer_completed?
  end
  
  def reject_completion?
    user.client? && job.user == user && job.freelancer_completed?
  end
  def client_accepted?
    # Only clients can access this action
    user.client?
  end
  
  class Scope < Scope
    def resolve
      if user.client?
        # Clients can only see their own jobs
        scope.where(user: user)
      elsif user.freelancer?
        # Freelancers see jobs where they have accepted proposals
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
end
