class CreateAdmins < ActiveRecord::Migration[7.2]
  def change
    create_table :admin_users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :yt_username, null: false
      t.string :yt_profile_picture_url

      t.timestamps
    end

    add_index :admin_users, :email, unique: true
  end
end
