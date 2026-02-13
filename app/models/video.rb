class Video < ApplicationRecord
  belongs_to :admin_user
  has_many :variants, -> { order(:position) }, dependent: :destroy
  has_many :variant_votes, dependent: :destroy
  has_many :video_shares, dependent: :destroy
  has_many :recipients, through: :video_shares

  validates :working_title, presence: true
  validates :share_token, presence: true, uniqueness: true

  before_validation :generate_share_token, on: :create

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
