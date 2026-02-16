class AddVotingStatusAndAbFields < ActiveRecord::Migration[7.2]
  def change
    add_column :videos, :status, :string, default: "voting", null: false
    add_column :variants, :ab_selected, :boolean, default: false, null: false
    add_column :variants, :ab_winner, :boolean, default: false, null: false
  end
end
