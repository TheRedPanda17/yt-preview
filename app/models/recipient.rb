class Recipient < ApplicationRecord
  belongs_to :admin_user

  has_many :video_shares, dependent: :destroy
  has_many :videos, through: :video_shares

  validates :name, presence: true, uniqueness: { scope: :admin_user_id, message: "already exists" }
end
