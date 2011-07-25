class AddRatingToPlayer < ActiveRecord::Migration
  def self.up
    add_column :players, :rating, :integer, :default => 1000
  end

  def self.down
    remove_column :players, :rating
  end
end
