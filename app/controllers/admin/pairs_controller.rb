module Admin
  class PairsController < BaseController
    before_action :set_video_and_variant
    before_action :set_pair, only: [:edit, :update, :destroy]

    def new
      @pair = @variant.title_thumbnail_pairs.build
    end

    def create
      @pair = @variant.title_thumbnail_pairs.build(pair_params)
      @pair.position = @variant.title_thumbnail_pairs.count
      if @pair.save
        redirect_to admin_video_path(@video), notice: "Title/thumbnail pair added!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @pair.update(pair_params)
        redirect_to admin_video_path(@video), notice: "Pair updated!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @pair.destroy
      redirect_to admin_video_path(@video), notice: "Pair removed."
    end

    private

    def set_video_and_variant
      @video = current_admin.videos.find(params[:video_id])
      @variant = @video.variants.find(params[:variant_id])
    end

    def set_pair
      @pair = @variant.title_thumbnail_pairs.find(params[:id])
    end

    def pair_params
      params.require(:title_thumbnail_pair).permit(:title, :thumbnail_url, :thumbnail)
    end
  end
end
