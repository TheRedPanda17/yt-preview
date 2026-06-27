class ConceptPair < ApplicationRecord
  belongs_to :concept
  has_one_attached :thumbnail

  validates :title, presence: true
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
    unless thumbnail.attached? || thumbnail_url.present?
      errors.add(:base, "A thumbnail image or URL is required")
    end
  end
end
