class CreatePairVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :pair_votes do |t|
      t.references :variant, null: false, foreign_key: true
      t.references :title_thumbnail_pair, null: false, foreign_key: true
      t.string :voter_name, null: false

      t.timestamps
    end

    add_index :pair_votes, [:variant_id, :voter_name], unique: true
  end
end
