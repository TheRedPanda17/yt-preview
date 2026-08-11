class PreviewsController < ApplicationController
  layout "preview"

  def show
    @video = Video.includes(
      :admin_user, :vote_feedbacks, :top_picks,
      video_shares: :recipient,
      concepts: { concept_pairs: { thumbnail_attachment: :blob }, concept_votes: [] },
      variants: { title_thumbnail_pairs: [ :pair_votes, :top_picks, { thumbnail_attachment: :blob } ] }
    ).find_by!(share_token: params[:share_token])
    @video_share = @video.video_shares.includes(:recipient).find_by!(token: params[:recipient_token])
    @recipient = @video_share.recipient
    @admin = @video.admin_user
    @variants = @video.variants.includes(:variant_votes)

    # Auto-set voter name from recipient
    cookies.signed.permanent[:voter_name] = @recipient.name

    # Precompute voter state (needed for both active voting and results)
    @my_concept_votes = @video.concepts.flat_map(&:concept_votes).select { |v| v.voter_name == voter_name }
    @my_variant_votes = @video.variant_votes.select { |v| v.voter_name == voter_name }
    @my_top_picks = @video.top_picks.select { |tp| tp.voter_name == voter_name }.sort_by(&:position)
    @existing_feedback = @video.vote_feedbacks.detect { |f| f.voter_name == voter_name }
    @my_pair_votes = @variants.each_with_object({}) do |v, h|
      pv = v.pair_votes.detect { |pv| pv.voter_name == voter_name }
      h[v.id] = pv.title_thumbnail_pair_id if pv
    end

    # If voting has ended, show results page instead of voting flow
    if @video.ended?
      @step = "results"
      return
    end

    # Concept planning flow
    if @video.concept_planning?
      setup_concept_planning_step
      return
    end

    # Determine current step
    @step = (params[:step] || "1").to_s
    @variant_index = [ (params[:vi] || "0").to_i, 0 ].max
    @variant_index = [ @variant_index, @variants.size - 1 ].min if @variants.any?

    # Step counts for progress bar
    @total_variants = @variants.size
    @variant_ranks_done = @my_variant_votes.size == @total_variants
    @pair_votes_cast = @variants.count { |v| v.pair_votes.any? { |pv| pv.voter_name == voter_name } }
    @all_pairs_voted = @pair_votes_cast == @total_variants
    @has_top_picks = @my_top_picks.size == 3
  rescue ActiveRecord::RecordNotFound
    render :unauthorized, layout: "preview", status: :not_found
  end

  def unauthorized
    render :unauthorized, layout: "preview", status: :forbidden
  end

  private

  def setup_concept_planning_step
    @concepts = @video.shuffled_concepts_for(voter_name)
    @total_concepts = @concepts.size
    @step = (params[:step] || "concept").to_s

    if @step == "concept"
      @concept_index = [ (params[:ci] || "0").to_i, 0 ].max
      @concept_index = [ @concept_index, @total_concepts - 1 ].min if @total_concepts > 0
      @concept_votes_cast = @my_concept_votes.size
      @all_concepts_rated = @concept_votes_cast == @total_concepts && @total_concepts > 0
    end
  end
end
