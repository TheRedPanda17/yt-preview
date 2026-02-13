class CreateVoteFeedbacks < ActiveRecord::Migration[7.2]
  def change
    create_table :vote_feedbacks do |t|
      t.references :video, null: false, foreign_key: true
      t.string :voter_name, null: false
      t.integer :interest_score, null: false
      t.text :comments

      t.timestamps
    end

    add_index :vote_feedbacks, [:video_id, :voter_name], unique: true
  end
end
