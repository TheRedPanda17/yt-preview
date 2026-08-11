module Admin
  class VariantsController < BaseController
    before_action :set_video
    before_action :set_variant, only: [ :show, :edit, :update, :destroy, :move ]

    def show
    end

    def new
      @variant = @video.variants.build
    end

    def create
      @variant = @video.variants.build(variant_params)
      @variant.position = @video.variants.count
      if @variant.save
        redirect_to admin_video_path(@video), notice: "Variant added!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @variant.update(variant_params)
        redirect_to admin_video_path(@video), notice: "Variant updated!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def move
      direction = params[:direction]
      variants = @video.variants.order(:position, :id).to_a

      variants.each_with_index { |v, i| v.update_column(:position, i) }

      variants = @video.variants.order(:position, :id).to_a
      index = variants.index(@variant)

      if direction == "up" && index > 0
        variants[index - 1].update_column(:position, index)
        @variant.update_column(:position, index - 1)
      elsif direction == "down" && index < variants.size - 1
        variants[index + 1].update_column(:position, index)
        @variant.update_column(:position, index + 1)
      end

      redirect_to admin_video_path(@video), notice: "Variant reordered."
    end

    def destroy
      @variant.destroy
      redirect_to admin_video_path(@video), notice: "Variant removed."
    end

    private

    def set_video
      @video = current_admin.videos.find(params[:video_id])
    end

    def set_variant
      @variant = @video.variants.find(params[:id])
    end

    def variant_params
      params.require(:variant).permit(:name)
    end
  end
end
