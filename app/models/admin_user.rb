class AdminUser < ApplicationRecord
  has_secure_password

  has_many :videos, dependent: :destroy
  has_many :recipients, dependent: :destroy
  has_many :channel_videos, -> { order(position: :desc, created_at: :desc) }, dependent: :destroy
  has_one_attached :profile_picture
  has_one_attached :channel_banner

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :yt_username, presence: true

  def avatar_url
    if profile_picture.attached?
      Rails.application.routes.url_helpers.rails_storage_proxy_path(profile_picture, only_path: true)
    elsif yt_profile_picture_url.present?
      yt_profile_picture_url
    end
  end

  def channel_banner_image_url
    if channel_banner.attached?
      Rails.application.routes.url_helpers.rails_storage_proxy_path(channel_banner, only_path: true)
    elsif channel_banner_url.present?
      channel_banner_url
    end
  end
end
