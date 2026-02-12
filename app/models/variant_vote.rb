class VariantVote < ApplicationRecord
  belongs_to :video
  belongs_to :variant

  validates :voter_name, presence: true
  validates :voter_name, uniqueness: { scope: :video_id, message: "has already voted for this video" }
end
