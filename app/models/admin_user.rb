class AdminUser < ApplicationRecord
  has_secure_password

  has_many :videos, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :yt_username, presence: true
end
