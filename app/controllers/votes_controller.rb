class VotesController < ApplicationController
  before_action :set_video
  before_action :require_voter

  def vote_variant
    variant = @video.variants.find(params[:variant_id])

    vote = @video.variant_votes.find_or_initialize_by(voter_name: voter_name)
    vote.variant = variant

    if vote.save
      redirect_to preview_path(@video.share_token), notice: "Vote recorded!"
    else
      redirect_to preview_path(@video.share_token), alert: "Could not record vote."
    end
  end

  def vote_pair
    variant = @video.variants.find(params[:variant_id])
    pair = variant.title_thumbnail_pairs.find(params[:pair_id])

    vote = variant.pair_votes.find_or_initialize_by(voter_name: voter_name)
    vote.title_thumbnail_pair = pair

    if vote.save
      redirect_to preview_path(@video.share_token), notice: "Pair vote recorded!"
    else
      redirect_to preview_path(@video.share_token), alert: "Could not record vote."
    end
  end

  private

  def set_video
    @video = Video.find_by!(share_token: params[:share_token])
  end

  def require_voter
    unless voter_name.present?
      redirect_to preview_path(@video.share_token), alert: "Please enter your name first."
    end
  end
end
