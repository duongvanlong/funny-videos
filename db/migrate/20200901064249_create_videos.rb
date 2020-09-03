class CreateVideos < ActiveRecord::Migration[5.0]
  def change
    create_table :videos do |t|
      t.string :video_id
      t.string :title
      t.text :description
      t.string :publisher
      t.integer :votes_up
      t.integer :votes_down
      t.integer :user_id
      t.timestamps
    end
    add_index :videos, :video_id, unique: true
  end
end
