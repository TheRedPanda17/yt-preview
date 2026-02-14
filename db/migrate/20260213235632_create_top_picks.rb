class CreateTopPicks < ActiveRecord::Migration[7.2]
  def change
    create_table :top_picks do |t|
      t.references :video, null: false, foreign_key: true
      t.references :title_thumbnail_pair, null: false, foreign_key: true
      t.string :voter_name, null: false

      t.timestamps
    end
    add_index :top_picks, [:video_id, :title_thumbnail_pair_id, :voter_name], unique: true, name: "index_top_picks_uniqueness"
    add_index :top_picks, [:video_id, :voter_name], name: "index_top_picks_on_video_and_voter"
  end
end
