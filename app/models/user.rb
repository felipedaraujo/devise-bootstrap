class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 100 }

  def name
    [first_name, last_name].join(' ')
  end

  def should_generate_new_friendly_id?
    first_name_changed? or last_name_changed?
  end
end
