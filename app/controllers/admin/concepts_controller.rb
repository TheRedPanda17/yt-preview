module Admin
  class ConceptsController < BaseController
    before_action :set_video
    before_action :set_concept, only: [ :edit, :update, :destroy, :move, :pick ]

    def new
      @concept = @video.concepts.build
    end

    def create
      @concept = @video.concepts.build(concept_params)
      @concept.position = @video.concepts.count
      if @concept.save
        redirect_to admin_video_path(@video), notice: "Concept added!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @concept.update(concept_params)
        redirect_to admin_video_path(@video), notice: "Concept updated!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def move
      direction = params[:direction]
      concepts = @video.concepts.order(:position, :id).to_a

      concepts.each_with_index { |c, i| c.update_column(:position, i) }

      concepts = @video.concepts.order(:position, :id).to_a
      index = concepts.index(@concept)

      if direction == "up" && index > 0
        concepts[index - 1].update_column(:position, index)
        @concept.update_column(:position, index - 1)
      elsif direction == "down" && index < concepts.size - 1
        concepts[index + 1].update_column(:position, index)
        @concept.update_column(:position, index + 1)
      end

      redirect_to admin_video_path(@video), notice: "Concept reordered."
    end

    def pick
      @video.concepts.update_all(picked: false)
      @concept.update!(picked: true)
      redirect_to admin_video_path(@video), notice: "#{@concept.name} marked as the picked concept."
    end

    def destroy
      @concept.destroy
      redirect_to admin_video_path(@video), notice: "Concept removed."
    end

    private

    def set_video
      @video = current_admin.videos.find(params[:video_id])
    end

    def set_concept
      @concept = @video.concepts.find(params[:id])
    end

    def concept_params
      params.require(:concept).permit(:name)
    end
  end
end
