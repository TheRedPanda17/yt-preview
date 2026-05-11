class AddChannelBrandingToAdminUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :admin_users, :channel_banner_url, :string
    add_column :admin_users, :subscriber_count, :string
  end
end
