module Admin
  class VideosController < BaseController
    before_action :set_video, only: [ :show, :edit, :update, :destroy, :end_voting, :reopen_voting, :begin_concept_planning, :advance_to_voting, :update_ab_results, :preview_voting, :concept_results, :voting_results, :compose, :channel_preview, :channel_preview_pair, :create_pair, :create_concept_pair, :create_variant_inline, :create_concept_inline ]
    before_action :load_video_with_vote_data, only: [ :show, :concept_results, :voting_results, :update_ab_results ]

    def index
      @videos = current_admin.videos.order(created_at: :desc)
    end

    def show
    end

    def concept_results
    end

    def voting_results
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

    def end_voting
      @video.update!(status: "ended")
      redirect_to voting_results_admin_video_path(@video), notice: "Voting ended. Record A/B test results on the voting results page."
    end

    def reopen_voting
      @video.update!(status: "voting")
      redirect_to admin_video_path(@video), notice: "Voting reopened."
    end

    def begin_concept_planning
      @video.update!(status: "concept_planning")
      redirect_to admin_video_path(@video), notice: "Concept planning started. Share the link so voters can rate concepts."
    end

    def advance_to_voting
      unless @video.picked_concept
        redirect_to admin_video_path(@video), alert: "Pick a concept before advancing to thumbnail voting."
        return
      end

      @video.update!(status: "voting")
      redirect_to admin_video_path(@video), notice: "Advanced to thumbnail voting."
    end

    def update_ab_results
      ab_selected_ids = Array(params[:ab_selected_pair_ids]).map(&:to_i)
      ab_winner_id = params[:ab_winner_pair_id].presence&.to_i

      all_pairs = @video.variants.flat_map(&:title_thumbnail_pairs)
      all_pairs.each do |pair|
        pair.update!(
          ab_selected: ab_selected_ids.include?(pair.id),
          ab_winner: pair.id == ab_winner_id
        )
      end

      redirect_to voting_results_admin_video_path(@video), notice: "A/B test results updated."
    end

    def preview_voting
      recipient = current_admin.recipients.find_or_create_by!(name: current_admin.yt_username)
      share = @video.video_shares.find_or_create_by!(recipient: recipient)
      redirect_to share.preview_url(request), allow_other_host: false
    end

    def compose
      @video = current_admin.videos.includes(:concepts, variants: { title_thumbnail_pairs: { thumbnail_attachment: :blob } }).find(params[:id])
    end

    def channel_preview
      @video = current_admin.videos.includes(variants: { title_thumbnail_pairs: { thumbnail_attachment: :blob } }).find(params[:id])
      @preview_pairs = @video.variants.flat_map(&:title_thumbnail_pairs).select(&:has_thumbnail?)
    end

    def channel_preview_pair
      @video = current_admin.videos.includes(variants: { title_thumbnail_pairs: { thumbnail_attachment: :blob } }).find(params[:id])
      @preview_pair = @video.variants.flat_map(&:title_thumbnail_pairs).detect { |pair| pair.id == params[:pair_id].to_i }

      unless @preview_pair
        redirect_to channel_preview_admin_video_path(@video), alert: "Choose a saved preview variant first."
        return
      end

      @channel_videos = current_admin.channel_videos.with_attached_thumbnail
      render :channel_preview_pair, layout: false
    end

    def create_pair
      variant = @video.variants.find(params[:variant_id])
      pair = variant.title_thumbnail_pairs.build(
        title: params[:title],
        thumbnail: params[:thumbnail]
      )
      pair.position = variant.title_thumbnail_pairs.count
      if pair.save
        redirect_to compose_admin_video_path(@video), notice: "Pair added to #{variant.name}!"
      else
        redirect_to compose_admin_video_path(@video), alert: "Could not save pair: #{pair.errors.full_messages.join(', ')}"
      end
    end

    def create_concept_pair
      concept = @video.concepts.find(params[:concept_id])
      pair = concept.concept_pairs.build(
        title: params[:title],
        thumbnail: params[:thumbnail]
      )
      pair.position = concept.concept_pairs.count
      if pair.save
        redirect_to compose_admin_video_path(@video), notice: "Pair added to #{concept.name}!"
      else
        redirect_to compose_admin_video_path(@video), alert: "Could not save concept pair: #{pair.errors.full_messages.join(', ')}"
      end
    end

    def create_variant_inline
      variant = @video.variants.build(name: params[:name])
      variant.position = @video.variants.count
      if variant.save
        render json: { id: variant.id, name: variant.name }, status: :created
      else
        render json: { error: variant.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    def create_concept_inline
      concept = @video.concepts.build(name: params[:name])
      concept.position = @video.concepts.count
      if concept.save
        render json: { id: concept.id, name: concept.name }, status: :created
      else
        render json: { error: concept.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    private

    def load_video_with_vote_data
      @video = current_admin.videos.includes(
        :variant_votes,
        :vote_feedbacks,
        :top_picks,
        video_shares: :recipient,
        concepts: {
          concept_pairs: { thumbnail_attachment: :blob },
          concept_votes: []
        },
        variants: {
          title_thumbnail_pairs: [ :pair_votes, :top_picks, { thumbnail_attachment: :blob } ],
          variant_votes: [],
          pair_votes: []
        }
      ).find(params[:id])

      concept_voter_names = @video.concepts.flat_map { |c| c.concept_votes.map(&:voter_name) }
      variant_voter_names = @video.variant_votes.map(&:voter_name)
      pair_voter_names = @video.variants.flat_map { |v| v.pair_votes.map(&:voter_name) }
      top_pick_voter_names = @video.top_picks.map(&:voter_name)
      @all_voters = (concept_voter_names + variant_voter_names + pair_voter_names + top_pick_voter_names).uniq.sort
    end

    def set_video
      @video = current_admin.videos.find(params[:id])
    end

    def video_params
      params.require(:video).permit(:working_title, :sample_views, :video_duration, :youtube_url, :share_message)
    end
  end
end
