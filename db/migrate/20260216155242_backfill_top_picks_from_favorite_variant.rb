class BackfillTopPicksFromFavoriteVariant < ActiveRecord::Migration[7.2]
  def up
    # For voters who ranked variants and picked favorite pairs but never
    # submitted top 3 picks: auto-create a #1 top pick from their favorite
    # pair in their #1-ranked variant.
    voters_with_top_picks = TopPick.distinct.pluck(:video_id, :voter_name).to_set

    VariantVote.where(position: 1).find_each do |vv|
      key = [vv.video_id, vv.voter_name]
      next if voters_with_top_picks.include?(key)

      pair_vote = PairVote.find_by(variant_id: vv.variant_id, voter_name: vv.voter_name)
      next unless pair_vote

      TopPick.create!(
        video_id: vv.video_id,
        title_thumbnail_pair_id: pair_vote.title_thumbnail_pair_id,
        voter_name: vv.voter_name,
        position: 1
      )

      voters_with_top_picks.add(key)
    end
  end

  def down
    # Not reversible in a meaningful way
  end
end
