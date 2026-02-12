class PreviewsController < ApplicationController
  layout "preview"

  def show
    @video = Video.includes(:admin_user, variants: { title_thumbnail_pairs: [:pair_votes, { thumbnail_attachment: :blob }] }).find_by!(share_token: params[:share_token])
    @admin = @video.admin_user
    @variants = @video.variants.includes(:variant_votes)
  end

  def identify
    @video = Video.find_by!(share_token: params[:share_token])
    name = params[:voter_name].to_s.strip
    if name.present?
      cookies.signed.permanent[:voter_name] = name
      redirect_to preview_path(@video.share_token), notice: "Welcome, #{name}!"
    else
      redirect_to preview_path(@video.share_token), alert: "Please enter a name."
    end
  end
end
