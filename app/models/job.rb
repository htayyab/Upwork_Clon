class Job < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :proposals, dependent: :destroy

  enum :status, {
    open: 0,
    closed: 1,
    freelancer_completed: 2,
    client_completed: 3,
    completed: 4,
    archived: 5 # ✅ Added for logical deletion
  }

  enum :complexity, { low: 0, medium: 1, high: 2 }

  serialize :skills, coder: JSON
  
  #Server Side Validations on jobs 
  validates :title, :description, :budget,:user_id,:category_id,:skills, presence: true
  validates :title, length: { minimum: 10, maximum: 50 }
  validates :description, length: { minimum: 20, maximum: 200 }
  validates :budget, numericality: { greater_than: 0 }

  # ========== Skill handling for forms ==========
  def skills_string
    skills&.join(', ')
  end

  def skills_string=(value)
    self.skills = if value.is_a?(Array)
      value.map(&:strip).reject(&:blank?)
    else
      value.to_s.split(',').map(&:strip).reject(&:blank?)
    end
  end

  # ========== Proposal-related helpers ==========

  #check the user is freelancer and check the freelancer is already applied for job
  
  def applied_by?(user)
    return false unless user.freelancer?
    proposals.exists?(user_id: user.id)
  end
  
  # fetch all the proposals submited by freelancer
  def user_proposal(user)
    proposals.find_by(user_id: user.id)
  end

  #fetch all propsals with accepted status by Client 
  def accepted_proposal
    proposals.find_by(status: 'accepted')
  end

  
  # ========== Completion State Logic ==========
  def can_freelancer_complete?(user)
    closed? && proposals.exists?(user_id: user.id, status: 'accepted')
  end

  def mark_as_freelancer_completed_by(user)
    return false unless can_freelancer_complete?(user)
    update(status: :freelancer_completed)
  end

  def approve_completion!
    return false unless freelancer_completed?
    transaction do
      update!(status: :completed)
      release_payment
    end
    true
  rescue => e
    Rails.logger.error("Payment release failed: #{e.message}")
    false
  end

  def reject_completion!
    return false unless freelancer_completed?
    update(status: :closed)
  end

  private

  

  def release_payment
    accepted_proposal&.then do |proposal|
      proposal.user.increment!(:balance, proposal.offer_amount * 0.8)
      proposal.update!(hold_amount: 0)
    end
  end


  # Scope to exclude archived jobs (for public-facing listings)
  def self.all_jobs_excluded_archived(user)
    where(user_id: user.id).where.not(status: :archived).order(created_at: :desc)
  end

  # show list of Accepted jobs for client and freelancer 
  def self.accepted_jobs(user)
    if user.client?
      Job.includes(:proposals).where(id: Proposal.where(status: :accepted).select(:job_id))
        .where(user_id: user.id)
    else
      Job.includes(:proposals).where(id: Proposal.where(user_id: user.id, status: :accepted ).select(:job_id))    
    end
  end



  #searching business logic used in search controller 
  def self.search_by(query, filter = 'title')
    query = query.to_s.strip.downcase
    jobs = where(status: :open )  # Always restrict to open jobs unless explicitly overridden
  
    return jobs.order(created_at: :desc) if query.blank?
  
    case filter
    when 'title'
      jobs = jobs.where('LOWER(title) LIKE ?', "%#{query}%")
    when 'budget'
      jobs = search_by_budget(query, jobs)
    when 'category'
      jobs = search_by_category(query, jobs)
    when 'skills'
      jobs = search_by_skills(query, jobs)
    else
      none  # Invalid filter
    end
  
    jobs.order(created_at: :desc).limit(50)
  end
  
  # 'search_by_budget' method
  def self.search_by_budget(query, jobs)
    num = query.gsub(/[^\d.]/, '').to_f
    return jobs.none if num.zero?
  
    # Apply budget filter
    if query.include?('..')
      min, max = query.split('..').map { |n| n.gsub(/[^\d.]/, '').to_f }
      jobs = jobs.where(budget: min..max)
    else
      jobs = jobs.where('budget >= ?', num)
    end
    jobs
  end
  
  # 'search_by_category' method (assuming `categories` is a related model)
  def self.search_by_category(query, jobs)
    return jobs if query.blank?
    categories = Category.where('LOWER(name) LIKE ?', "%#{query.downcase}%").pluck(:id)
    jobs = jobs.where(category_id: categories) unless categories.empty?
    jobs
  end
  
  # 'search_by_skills' method (assuming skills are stored in a serialized array)
  def self.search_by_skills(query, jobs)
    skills = query.split(',').map(&:strip).reject(&:blank?).map(&:downcase)
    return jobs if skills.empty?
  
    filtered = jobs.to_a.select do |job|
      job_skills = job.skills.map(&:to_s).map(&:strip).reject(&:blank?).map(&:downcase)
      (job_skills & skills).any?
    end
    jobs.where(id: filtered)
  end

end




