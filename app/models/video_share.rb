class VideoShare < ApplicationRecord
  belongs_to :video
  belongs_to :recipient

  validates :token, presence: true, uniqueness: true
  validates :recipient_id, uniqueness: { scope: :video_id, message: "already has access to this video" }

  before_validation :generate_token, on: :create

  def preview_url(request = nil)
    if request
      "#{request.base_url}/p/#{video.share_token}/r/#{token}"
    else
      "/p/#{video.share_token}/r/#{token}"
    end
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(12)
  end
end
