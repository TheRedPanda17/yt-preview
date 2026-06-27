class AddConceptPlanning < ActiveRecord::Migration[7.2]
  def change
    create_table :concepts do |t|
      t.references :video, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, default: 0, null: false
      t.boolean :picked, default: false, null: false
      t.timestamps
    end

    create_table :concept_pairs do |t|
      t.references :concept, null: false, foreign_key: true
      t.string :title, null: false
      t.string :thumbnail_url
      t.integer :position, default: 0, null: false
      t.timestamps
    end

    create_table :concept_votes do |t|
      t.references :concept, null: false, foreign_key: true
      t.string :voter_name, null: false
      t.integer :interest_score, null: false
      t.timestamps
      t.index [ :concept_id, :voter_name ], unique: true
    end
  end
end
