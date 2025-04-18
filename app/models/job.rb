class Job < ApplicationRecord
  has_many :proposals
  belongs_to :user
  enum :status, { 
    open: 0, 
    closed: 1, 
    freelancer_completed: 2, 
    client_completed: 3, 
    completed: 4 
  }

  belongs_to :category
  enum :complexity, { low: 0, medium: 1, high: 2 }

  serialize :skills, coder: JSON
  validates :title, :description, :budget, presence: true

  # Getter for form: turn array into comma-separated string
  def skills_string
    skills&.join(', ')
  end

  # Setter from form input (array from Select2 or comma string)
  def skills_string=(value)
    self.skills = if value.is_a?(Array)
      value.map(&:strip).reject(&:blank?)
    else
      value.to_s.split(',').map(&:strip).reject(&:blank?)
    end
  end

  def can_freelancer_complete?(user)
    closed? && proposals.exists?(user_id: user.id, status: 'accepted')
  end

  def can_client_complete?(user)
    freelancer_completed? && self.user == user
  end

  def applied_by?(user)
    return false unless user.freelancer?
    proposals.exists?(user_id: user.id)
  end

  def accepted_proposal
    proposals.find_by(status: 'accepted')
  end
end