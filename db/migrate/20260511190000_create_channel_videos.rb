class CreateChannelVideos < ActiveRecord::Migration[7.2]
  def change
    create_table :channel_videos do |t|
      t.references :admin_user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :thumbnail_url
      t.string :view_count, default: "1.2K views", null: false
      t.string :published_at_label, default: "1 day ago", null: false
      t.string :duration
      t.string :youtube_url
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :channel_videos, [ :admin_user_id, :position ]
  end
end
