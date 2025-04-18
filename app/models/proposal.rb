class Proposal < ApplicationRecord
  has_many_attached :attachments
  belongs_to :job
  belongs_to :user  # Direct association with User model

  enum :status, {
    pending: 'pending',
    accepted: 'accepted',
    rejected: 'rejected'
  }
  
  # Validations
  validates :user, presence: true
  validates :status, presence: true
  validates :job, presence: true

  # Ensure only freelancers can be assigned
  validate :user_must_be_freelancer

  private
  
  def user_must_be_freelancer
    return unless user
    unless user.freelancer?
      errors.add(:user, "must be a freelancer")
    end
  end
end