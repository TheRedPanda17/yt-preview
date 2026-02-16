class Video < ApplicationRecord
  STATUSES = %w[voting ended].freeze

  belongs_to :admin_user
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

  def voting?
    status == "voting"
  end

  def ended?
    status == "ended"
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

  def generate_share_token
    self.share_token ||= SecureRandom.urlsafe_base64(8)
  end
end
