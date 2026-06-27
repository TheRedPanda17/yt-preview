class Concept < ApplicationRecord
  belongs_to :video
  has_many :concept_pairs, -> { order(:position) }, dependent: :destroy
  has_many :concept_votes, dependent: :destroy

  validates :name, presence: true
end
