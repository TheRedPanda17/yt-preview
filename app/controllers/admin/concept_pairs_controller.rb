module Admin
  class ConceptPairsController < BaseController
    before_action :set_video_and_concept
    before_action :set_pair, only: [ :edit, :update, :destroy, :move ]

    def new
      @pair = @concept.concept_pairs.build
      @pair.title = prefill_title
    end

    def create
      @pair = @concept.concept_pairs.build(pair_params)
      @pair.position = @concept.concept_pairs.count
      if @pair.save
        redirect_to admin_video_path(@video), notice: "Concept pair added!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @pair.update(pair_params)
        redirect_to admin_video_path(@video), notice: "Concept pair updated!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def move
      direction = params[:direction]
      pairs = @concept.concept_pairs.order(:position, :id).to_a

      pairs.each_with_index { |p, i| p.update_column(:position, i) }

      pairs = @concept.concept_pairs.order(:position, :id).to_a
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
      redirect_to admin_video_path(@video), notice: "Concept pair removed."
    end

    private

    def set_video_and_concept
      @video = current_admin.videos.find(params[:video_id])
      @concept = @video.concepts.find(params[:concept_id])
    end

    def set_pair
      @pair = @concept.concept_pairs.find(params[:id])
    end

    def pair_params
      params.require(:concept_pair).permit(:title, :thumbnail_url, :thumbnail)
    end

    def prefill_title
      first_in_concept = @concept.concept_pairs.order(:position, :id).first
      return first_in_concept.title if first_in_concept

      other_pair = ConceptPair.joins(:concept)
        .where(concepts: { video_id: @video.id })
        .where.not(concept_id: @concept.id)
        .order(:position, :id)
        .first
      return other_pair.title if other_pair

      @video.working_title
    end
  end
end
