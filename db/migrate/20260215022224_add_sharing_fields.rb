class AddSharingFields < ActiveRecord::Migration[7.2]
  def change
    add_column :recipients, :share_url, :string
    add_column :videos, :youtube_url, :string
    add_column :videos, :share_message, :text
  end
end
