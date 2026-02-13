class CreateRecipients < ActiveRecord::Migration[7.2]
  def change
    create_table :recipients do |t|
      t.references :video, null: false, foreign_key: true
      t.string :name, null: false
      t.string :token, null: false

      t.timestamps
    end

    add_index :recipients, :token, unique: true
    add_index :recipients, [:video_id, :name], unique: true
  end
end
