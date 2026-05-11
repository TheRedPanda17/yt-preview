class ChannelVideo < ApplicationRecord
  belongs_to :admin_user

  has_one_attached :thumbnail

  validates :title, presence: true
  validates :view_count, presence: true
  validates :published_at_label, presence: true
  validate :thumbnail_present

  def thumbnail_display_url
    if thumbnail.attached?
      thumbnail
    else
      thumbnail_url
    end
  end

  def has_thumbnail?
    thumbnail.attached? || thumbnail_url.present?
  end

  private

  def thumbnail_present
    return if has_thumbnail?

    errors.add(:base, "A thumbnail image or URL is required")
  end
end
