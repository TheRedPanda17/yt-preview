class MoveAbFieldsToTitleThumbnailPairs < ActiveRecord::Migration[7.2]
  def change
    remove_column :variants, :ab_selected, :boolean, default: false, null: false
    remove_column :variants, :ab_winner, :boolean, default: false, null: false

    add_column :title_thumbnail_pairs, :ab_selected, :boolean, default: false, null: false
    add_column :title_thumbnail_pairs, :ab_winner, :boolean, default: false, null: false
  end
end
