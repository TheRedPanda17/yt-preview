class RefactorRecipientsAndCreateVideoShares < ActiveRecord::Migration[7.2]
  def change
    # Create video_shares join table
    create_table :video_shares do |t|
      t.references :video, null: false, foreign_key: true
      t.references :recipient, null: false, foreign_key: true
      t.string :token, null: false

      t.timestamps
    end

    add_index :video_shares, :token, unique: true
    add_index :video_shares, [:video_id, :recipient_id], unique: true

    # Migrate existing recipients: move video_id -> admin_user_id
    # First add admin_user_id column
    add_reference :recipients, :admin_user, foreign_key: true

    # Migrate data: set admin_user_id from the video's admin_user
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE recipients
          SET admin_user_id = videos.admin_user_id
          FROM videos
          WHERE recipients.video_id = videos.id
        SQL

        # Create video_shares from existing recipients
        execute <<-SQL
          INSERT INTO video_shares (video_id, recipient_id, token, created_at, updated_at)
          SELECT video_id, id, token, created_at, updated_at
          FROM recipients
        SQL
      end
    end

    # Remove video-specific columns from recipients
    remove_index :recipients, [:video_id, :name]
    remove_index :recipients, :token
    remove_reference :recipients, :video, foreign_key: true
    remove_column :recipients, :token, :string

    # Make admin_user_id not null now that data is migrated
    change_column_null :recipients, :admin_user_id, false

    # Add unique index on admin_user_id + name
    add_index :recipients, [:admin_user_id, :name], unique: true
  end
end
