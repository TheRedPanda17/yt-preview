class ProfilesController < ApplicationController
  layout "preview"

  def show
    unless voter_name
      redirect_to root_path, alert: "No voter profile found."
      return
    end

    # Find all recipients matching this voter name (could span multiple admins)
    recipient_ids = Recipient.where(name: voter_name).pluck(:id)

    # Get all video shares for these recipients, with eager-loaded associations
    @video_shares = VideoShare
      .where(recipient_id: recipient_ids)
      .includes(video: [:admin_user, { variants: { title_thumbnail_pairs: { thumbnail_attachment: :blob } } }], recipient: [])
      .order(created_at: :desc)

    # Precompute voting progress per video
    voted_video_ids = VariantVote.where(voter_name: voter_name).select(:video_id).distinct.pluck(:video_id)
    feedback_video_ids = VoteFeedback.where(voter_name: voter_name).pluck(:video_id)

    @voting_progress = {}
    concept_vote_video_ids = ConceptVote.joins(:concept).where(concepts: { video_id: @video_shares.map(&:video_id) }, voter_name: voter_name).pluck("concepts.video_id").uniq

    @video_shares.each do |vs|
      video = vs.video
      has_concept_votes = concept_vote_video_ids.include?(video.id)
      has_votes = voted_video_ids.include?(video.id)
      has_feedback = feedback_video_ids.include?(video.id)

      @voting_progress[video.id] = if video.concept_planning?
                                       if has_concept_votes
                                         :completed
                                       else
                                         :not_started
                                       end
                                     elsif has_feedback
                                       :completed
                                     elsif has_votes
                                       :in_progress
                                     else
                                       :not_started
                                     end
    end
  end
end
