class Job < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :proposals

  enum :status, {
    open: 0,
    closed: 1,
    freelancer_completed: 2,
    client_completed: 3,
    completed: 4
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

  # ========== Scopes for clean queries ==========
  scope :client_accepted_by, ->(user) {
    joins(:proposals)
      .where(user: user, proposals: { status: 'accepted' })
      .distinct
      .includes(:proposals, :user)
  }

  scope :freelancer_accepted_for, ->(user) {
    if user.client?
      where(user: user).includes(:user, :proposals)
    else
      joins(:proposals)
        .where(proposals: { user_id: user.id, status: 'accepted' })
        .includes(:user, :proposals)
    end
  }


  #searching business logic used in search controller 

  def self.search_by(query, filter)
    query = query.to_s.strip.downcase
    return none if query.blank?

    case filter
    when 'title'
      where('LOWER(title) LIKE ?', "%#{query}%")
    when 'budget'
      search_by_budget(query)
    when 'category'
      joins(:category).where('LOWER(categories.name) LIKE ?', "%#{query}%")
    when 'skills'
      search_by_skills(query)
    else
      none
    end.order(created_at: :desc).limit(50)
  end

  def self.search_by_budget(query)
    num = query.gsub(/[^\d.]/, '').to_f
    return none if num.zero?

    return where('budget >= ?', num) if query !~ /[<>=]|\.\./

    case query
    when /^>=/
      where('budget >= ?', num)
    when /^<=/
      where('budget <= ?', num)
    when /^>/
      where('budget > ?', num)
    when /^</
      where('budget < ?', num)
    when /../
      min, max = query.split('..').map { |n| n.gsub(/[^\d.]/, '').to_f }
      where(budget: min..max)
    else
      where('budget >= ?', num)
    end
  end

  def self.search_by_skills(query)
    skills = query.split(',').map(&:strip).reject(&:blank?)
    return none if skills.empty?

    conditions = skills.map { "LOWER(jobs.skills) LIKE ?" }.join(' OR ')
    values = skills.map { |s| "%\"#{s}\"%" }
    where(conditions, *values)
  end

end
