class AddPositionToVariantVotesAndChangeIndex < ActiveRecord::Migration[7.2]
  def up
    # Add position column (default 0 temporarily for existing rows)
    add_column :variant_votes, :position, :integer, null: false, default: 0

    # Migrate existing data: existing single votes become #1 picks
    execute "UPDATE variant_votes SET position = 1"

    # Remove old unique index (one vote per voter per video)
    remove_index :variant_votes, name: "index_variant_votes_on_video_id_and_voter_name"

    # Add new unique index (one vote per voter per variant per video)
    add_index :variant_votes, [:video_id, :variant_id, :voter_name],
              unique: true, name: "index_variant_votes_on_video_variant_voter"

    # Also add a unique index on position per voter per video (can't have two #1s)
    add_index :variant_votes, [:video_id, :voter_name, :position],
              unique: true, name: "index_variant_votes_on_video_voter_position"
  end

  def down
    remove_index :variant_votes, name: "index_variant_votes_on_video_voter_position"
    remove_index :variant_votes, name: "index_variant_votes_on_video_variant_voter"

    # Keep only position=1 rows before restoring old constraint
    execute "DELETE FROM variant_votes WHERE position != 1"

    add_index :variant_votes, [:video_id, :voter_name],
              unique: true, name: "index_variant_votes_on_video_id_and_voter_name"

    remove_column :variant_votes, :position
  end
end
