class TitleThumbnailPair < ApplicationRecord
  belongs_to :variant
  has_many :pair_votes, dependent: :destroy
  has_many :top_picks, dependent: :destroy

  has_one_attached :thumbnail

  validates :title, presence: true
  validate :thumbnail_present

  scope :ab_selected, -> { where(ab_selected: true) }
  scope :ab_winner, -> { where(ab_winner: true) }

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

  def vote_count
    pair_votes.count
  end

  private

  def thumbnail_present
    unless thumbnail.attached? || thumbnail_url.present?
      errors.add(:base, "A thumbnail image or URL is required")
    end
  end
end
