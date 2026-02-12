class CreateTitleThumbnailPairs < ActiveRecord::Migration[7.2]
  def change
    create_table :title_thumbnail_pairs do |t|
      t.references :variant, null: false, foreign_key: true
      t.string :title, null: false
      t.string :thumbnail_url
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
