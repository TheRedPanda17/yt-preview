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
