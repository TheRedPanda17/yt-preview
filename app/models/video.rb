class Video < ApplicationRecord
  STATUSES = %w[concept_planning voting ended].freeze

  belongs_to :admin_user
  has_many :concepts, -> { order(:position) }, dependent: :destroy
  has_many :variants, -> { order(:position) }, dependent: :destroy
  has_many :variant_votes, dependent: :destroy
  has_many :vote_feedbacks, dependent: :destroy
  has_many :top_picks, dependent: :destroy
  has_many :video_shares, dependent: :destroy
  has_many :recipients, through: :video_shares

  validates :working_title, presence: true
  validates :share_token, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  before_validation :generate_share_token, on: :create

  def concept_planning?
    status == "concept_planning"
  end

  def voting?
    status == "voting"
  end

  def ended?
    status == "ended"
  end

  def picked_concept
    concepts.find_by(picked: true)
  end

  def shuffled_concepts_for(voter_name)
    concepts.to_a.shuffle(random: Random.new(concept_shuffle_seed(voter_name)))
  end

  def clear_votes_for!(voter_name)
    transaction do
      variant_votes.where(voter_name: voter_name).delete_all
      PairVote.where(variant_id: variants.select(:id), voter_name: voter_name).delete_all
      top_picks.where(voter_name: voter_name).delete_all
      vote_feedbacks.where(voter_name: voter_name).delete_all
      ConceptVote.where(concept_id: concepts.select(:id), voter_name: voter_name).delete_all
    end
  end

  def all_pairs
    TitleThumbnailPair.joins(:variant).where(variants: { video_id: id }).order(:position)
  end

  def ab_selected_pairs
    all_pairs.where(ab_selected: true)
  end

  def ab_winner_pair
    all_pairs.find_by(ab_winner: true)
  end

  def share_url(request = nil)
    if request
      "#{request.base_url}/p/#{share_token}"
    else
      "/p/#{share_token}"
    end
  end

  private

  def concept_shuffle_seed(voter_name)
    Digest::SHA256.hexdigest("#{voter_name}-#{id}-concepts").to_i(16)
  end

  def generate_share_token
    self.share_token ||= SecureRandom.urlsafe_base64(8)
  end
end
