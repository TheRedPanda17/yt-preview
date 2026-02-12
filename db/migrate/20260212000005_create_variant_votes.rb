class CreateVariantVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :variant_votes do |t|
      t.references :video, null: false, foreign_key: true
      t.references :variant, null: false, foreign_key: true
      t.string :voter_name, null: false

      t.timestamps
    end

    add_index :variant_votes, [:video_id, :voter_name], unique: true
  end
end
