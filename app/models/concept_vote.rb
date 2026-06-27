class ConceptVote < ApplicationRecord
  belongs_to :concept

  validates :voter_name, presence: true
  validates :interest_score, presence: true, inclusion: { in: 1..10 }
  validates :concept_thoughts, presence: true
  validates :improvement_suggestions, presence: true
  validates :voter_name, uniqueness: { scope: :concept_id }
end
