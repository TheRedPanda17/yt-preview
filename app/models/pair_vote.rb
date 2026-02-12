class PairVote < ApplicationRecord
  belongs_to :variant
  belongs_to :title_thumbnail_pair

  validates :voter_name, presence: true
  validates :voter_name, uniqueness: { scope: :variant_id, message: "has already voted for this variant's pairs" }
end
