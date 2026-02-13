module Admin
  class PairsController < BaseController
    before_action :set_video_and_variant
    before_action :set_pair, only: [:edit, :update, :destroy, :move]

    def new
      @pair = @variant.title_thumbnail_pairs.build
      @pair.title = prefill_title
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

    def move
      direction = params[:direction]
      pairs = @variant.title_thumbnail_pairs.order(:position, :id).to_a

      # Normalize positions first (fix any gaps or duplicates)
      pairs.each_with_index { |p, i| p.update_column(:position, i) }

      # Reload to get fresh positions
      pairs = @variant.title_thumbnail_pairs.order(:position, :id).to_a
      index = pairs.index(@pair)

      if direction == "up" && index > 0
        pairs[index - 1].update_column(:position, index)
        @pair.update_column(:position, index - 1)
      elsif direction == "down" && index < pairs.size - 1
        pairs[index + 1].update_column(:position, index)
        @pair.update_column(:position, index + 1)
      end

      redirect_to admin_video_path(@video), notice: "Pair reordered."
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

    def prefill_title
      # 1. First title in this variant
      first_in_variant = @variant.title_thumbnail_pairs.order(:position, :id).first
      return first_in_variant.title if first_in_variant

      # 2. Any title from any other variant
      other_pair = TitleThumbnailPair.joins(:variant)
        .where(variants: { video_id: @video.id })
        .where.not(variant_id: @variant.id)
        .order(:position, :id)
        .first
      return other_pair.title if other_pair

      # 3. The video's working title
      @video.working_title
    end
  end
end
