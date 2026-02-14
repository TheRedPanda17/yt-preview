class VariantVote < ApplicationRecord
  belongs_to :video
  belongs_to :variant

  validates :voter_name, presence: true
  validates :variant_id, uniqueness: { scope: [:video_id, :voter_name] }
  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :position, uniqueness: { scope: [:video_id, :voter_name] }
end
