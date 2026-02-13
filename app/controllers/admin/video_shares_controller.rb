module Admin
  class VideoSharesController < BaseController
    before_action :set_video

    def create
      recipient = current_admin.recipients.find(params[:recipient_id])
      @video_share = @video.video_shares.build(recipient: recipient)

      if @video_share.save
        redirect_to admin_video_path(@video), notice: "Shared with #{recipient.name}!"
      else
        redirect_to admin_video_path(@video), alert: @video_share.errors.full_messages.to_sentence
      end
    end

    def destroy
      @video_share = @video.video_shares.find(params[:id])
      name = @video_share.recipient.name
      @video_share.destroy
      redirect_to admin_video_path(@video), notice: "#{name} removed from this video."
    end

    private

    def set_video
      @video = current_admin.videos.find(params[:video_id])
    end
  end
end
