class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.integer :result
      t.integer :player_one_id
      t.integer :player_two_id

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
