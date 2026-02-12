class AddVideoDurationToVideos < ActiveRecord::Migration[7.2]
  def change
    add_column :videos, :video_duration, :string, default: "10:30"
  end
end
