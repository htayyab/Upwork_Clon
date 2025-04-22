class Proposal < ApplicationRecord
  has_many_attached :attachments
  belongs_to :job
  belongs_to :user  # Direct association with User model

  enum :status, { pending: 'pending', accepted: 'accepted', rejected: 'rejected' }
  #Server Side Validations 
  validates :user_id, :job_id,:status, :offer_amount, :cover_letter, :estimated_time, presence: true
  validates :offer_amount, numericality: { greater_than: 0 }
  validates :cover_letter, length: { minimum: 20, maximum: 200 }
  validates :estimated_time, format: {
    with: /\A\d+\s+(day|days|week|weeks|month|months|year|years)\z/i,
    message: "must be in format like '1 week', '2 months', etc."
  }
  validate :user_is_freelancer

  # === Business Logic ===

  def accept!
    return false unless pending?

    transaction do
      update!(status: :accepted, hold_amount: offer_amount)
      job.update!(status: :closed)
      job.user.decrement!(:balance, offer_amount)
    end
    true
  rescue => e
    Rails.logger.error("Proposal#accept! failed: #{e.message}")
    false
  end

  def reject!
    pending? && update(status: :rejected)
  end

  private

  def user_is_freelancer
    errors.add(:user, "must be a freelancer") unless user&.freelancer?
  end
end
