class VotesController < ApplicationController
  before_action :set_video
  before_action :set_video_share
  before_action :require_voter

  def vote_variant
    variant = @video.variants.find(params[:variant_id])

    vote = @video.variant_votes.find_or_initialize_by(voter_name: voter_name)
    vote.variant = variant

    if vote.save
      redirect_to preview_path(@video.share_token, @video_share.token), notice: "Vote recorded!"
    else
      redirect_to preview_path(@video.share_token, @video_share.token), alert: "Could not record vote."
    end
  end

  def vote_pair
    variant = @video.variants.find(params[:variant_id])
    pair = variant.title_thumbnail_pairs.find(params[:pair_id])

    vote = variant.pair_votes.find_or_initialize_by(voter_name: voter_name)
    vote.title_thumbnail_pair = pair

    if vote.save
      redirect_to preview_path(@video.share_token, @video_share.token), notice: "Pair vote recorded!"
    else
      redirect_to preview_path(@video.share_token, @video_share.token), alert: "Could not record vote."
    end
  end

  def vote_top_picks
    pair_ids = Array(params[:pair_ids]).map(&:to_i).uniq.first(3)

    if pair_ids.size != 3
      redirect_to preview_path(@video.share_token, @video_share.token), alert: "Please pick exactly 3 favorites."
      return
    end

    # Verify all pairs belong to this video
    all_pair_ids = @video.variants.flat_map { |v| v.title_thumbnail_pairs.map(&:id) }
    unless (pair_ids - all_pair_ids).empty?
      redirect_to preview_path(@video.share_token, @video_share.token), alert: "Invalid selection."
      return
    end

    ActiveRecord::Base.transaction do
      @video.top_picks.where(voter_name: voter_name).delete_all
      pair_ids.each_with_index do |pair_id, idx|
        @video.top_picks.create!(voter_name: voter_name, title_thumbnail_pair_id: pair_id, position: idx + 1)
      end
    end

    redirect_to preview_path(@video.share_token, @video_share.token), notice: "Top 3 picks saved!"
  end

  def submit_feedback
    feedback = @video.vote_feedbacks.find_or_initialize_by(voter_name: voter_name)
    feedback.interest_score = params[:interest_score]
    feedback.comments = params[:comments]

    if feedback.save
      redirect_to preview_path(@video.share_token, @video_share.token), notice: "Thanks for your feedback!"
    else
      redirect_to preview_path(@video.share_token, @video_share.token), alert: "Could not save feedback. Please pick an interest level."
    end
  end

  private

  def set_video
    @video = Video.find_by!(share_token: params[:share_token])
  end

  def set_video_share
    @video_share = @video.video_shares.find_by!(token: params[:recipient_token])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Invalid voting link."
  end

  def require_voter
    unless voter_name.present?
      redirect_to preview_path(@video.share_token, @video_share.token), alert: "Please enter your name first."
    end
  end
end
