class PreviewsController < ApplicationController
  layout "preview"

  def show
    @video = Video.includes(:admin_user, :vote_feedbacks, video_shares: :recipient, variants: { title_thumbnail_pairs: [:pair_votes, { thumbnail_attachment: :blob }] }).find_by!(share_token: params[:share_token])
    @video_share = @video.video_shares.includes(:recipient).find_by!(token: params[:recipient_token])
    @recipient = @video_share.recipient
    @admin = @video.admin_user
    @variants = @video.variants.includes(:variant_votes)

    # Auto-set voter name from recipient
    cookies.signed.permanent[:voter_name] = @recipient.name
  rescue ActiveRecord::RecordNotFound
    render :unauthorized, layout: "preview", status: :not_found
  end

  def unauthorized
    render :unauthorized, layout: "preview", status: :forbidden
  end
end
