class Variant < ApplicationRecord
  belongs_to :video
  has_many :title_thumbnail_pairs, -> { order(:position) }, dependent: :destroy
  has_many :variant_votes, dependent: :destroy
  has_many :pair_votes, dependent: :destroy

  validates :name, presence: true

  def vote_count
    variant_votes.count
  end
end
