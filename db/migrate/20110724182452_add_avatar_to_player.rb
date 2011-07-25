class AddAvatarToPlayer < ActiveRecord::Migration
  def self.up
    add_column :players, :avatar, :string
  end

  def self.down
    remove_column :players, :avatar
  end
end
