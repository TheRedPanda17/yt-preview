class VoteFeedback < ApplicationRecord
  belongs_to :video

  validates :voter_name, presence: true, uniqueness: { scope: :video_id }
  validates :interest_score, presence: true, inclusion: { in: 1..10 }
end
