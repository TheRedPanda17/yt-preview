class TopPick < ApplicationRecord
  belongs_to :video
  belongs_to :title_thumbnail_pair

  validates :voter_name, presence: true
  validates :title_thumbnail_pair_id, uniqueness: { scope: [:video_id, :voter_name], message: "already picked" }
  validate :max_three_per_voter

  private

  def max_three_per_voter
    existing = TopPick.where(video_id: video_id, voter_name: voter_name)
    existing = existing.where.not(id: id) if persisted?
    if existing.count >= 3
      errors.add(:base, "You can only pick 3 favorites")
    end
  end
end
