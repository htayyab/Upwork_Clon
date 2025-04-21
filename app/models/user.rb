class User < ApplicationRecord
  before_create :set_initial_balance
  
  has_many :jobs, dependent: :destroy
  has_many :proposals, foreign_key: :user_id, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { client: 0, freelancer: 1 }
  #User server side validations 
  validates :country, length: { maximum: 20}
  validates :first_name, :last_name, :country,:role, presence: true
  validates :first_name, :last_name, length: { minimum: 3, maximum: 20 }
  validates :role, inclusion: { in: roles.keys }

  private

  def set_initial_balance
    self.balance = role == "client" ? 100.0 : 0.0
  end

end
