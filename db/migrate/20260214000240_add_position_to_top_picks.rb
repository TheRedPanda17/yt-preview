class AddPositionToTopPicks < ActiveRecord::Migration[7.2]
  def change
    add_column :top_picks, :position, :integer, null: false, default: 0
  end
end
