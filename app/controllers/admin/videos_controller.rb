module Admin
  class VideosController < BaseController
    before_action :set_video, only: [:show, :edit, :update, :destroy]

    def index
      @videos = current_admin.videos.order(created_at: :desc)
    end

    def show
      @video = current_admin.videos.includes(variants: { title_thumbnail_pairs: [thumbnail_attachment: :blob] }).find(params[:id])
    end

    def new
      @video = current_admin.videos.build
    end

    def create
      @video = current_admin.videos.build(video_params)
      if @video.save
        redirect_to admin_video_path(@video), notice: "Video idea created!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @video.update(video_params)
        redirect_to admin_video_path(@video), notice: "Video updated!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @video.destroy
      redirect_to admin_videos_path, notice: "Video deleted."
    end

    private

    def set_video
      @video = current_admin.videos.find(params[:id])
    end

    def video_params
      params.require(:video).permit(:working_title, :sample_views)
    end
  end
end
