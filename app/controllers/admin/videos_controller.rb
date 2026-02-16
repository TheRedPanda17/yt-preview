module Admin
  class VideosController < BaseController
    before_action :set_video, only: [:show, :edit, :update, :destroy, :end_voting, :reopen_voting, :update_ab_results, :preview_voting]

    def index
      @videos = current_admin.videos.order(created_at: :desc)
    end

    def show
      @video = current_admin.videos.includes(
        :variant_votes,
        :vote_feedbacks,
        :top_picks,
        video_shares: :recipient,
        variants: {
          title_thumbnail_pairs: [:pair_votes, :top_picks, { thumbnail_attachment: :blob }],
          variant_votes: [],
          pair_votes: []
        }
      ).find(params[:id])

      # Collect all unique voter names across all vote types
      variant_voter_names = @video.variant_votes.map(&:voter_name)
      pair_voter_names = @video.variants.flat_map { |v| v.pair_votes.map(&:voter_name) }
      top_pick_voter_names = @video.top_picks.map(&:voter_name)
      @all_voters = (variant_voter_names + pair_voter_names + top_pick_voter_names).uniq.sort
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
      redirect_to admin_video_path(@video), notice: "Voting ended. Select the A/B tested variants below."
    end

    def reopen_voting
      @video.update!(status: "voting")
      redirect_to admin_video_path(@video), notice: "Voting reopened."
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

      redirect_to admin_video_path(@video), notice: "A/B test results updated."
    end

    def preview_voting
      recipient = current_admin.recipients.find_or_create_by!(name: current_admin.yt_username)
      share = @video.video_shares.find_or_create_by!(recipient: recipient)
      redirect_to share.preview_url(request), allow_other_host: false
    end

    private

    def set_video
      @video = current_admin.videos.find(params[:id])
    end

    def video_params
      params.require(:video).permit(:working_title, :sample_views, :video_duration, :youtube_url, :share_message)
    end
  end
end
