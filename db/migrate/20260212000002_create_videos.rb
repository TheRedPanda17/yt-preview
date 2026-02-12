class CreateVideos < ActiveRecord::Migration[7.2]
  def change
    create_table :videos do |t|
      t.references :admin_user, null: false, foreign_key: true
      t.string :working_title, null: false
      t.string :sample_views, default: "1.2K views"
      t.string :share_token, null: false

      t.timestamps
    end

    add_index :videos, :share_token, unique: true
  end
end
