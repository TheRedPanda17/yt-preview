class AddFeedbackToConceptVotes < ActiveRecord::Migration[7.2]
  def change
    add_column :concept_votes, :concept_thoughts, :text
    add_column :concept_votes, :improvement_suggestions, :text
  end
end
