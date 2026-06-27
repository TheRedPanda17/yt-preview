class ConceptVote < ApplicationRecord
  belongs_to :concept

  validates :voter_name, presence: true
  validates :interest_score, presence: true, inclusion: { in: 1..10 }
  validates :voter_name, uniqueness: { scope: :concept_id }
end
