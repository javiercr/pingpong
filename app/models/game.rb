require 'elo'

class Game < ActiveRecord::Base
  belongs_to :player_one, :class_name => "Player"
  belongs_to :player_two, :class_name => "Player"

  # Every time a result is set, it tells the Elo::Player
	# objects to update their scores.
  def process_result(new_result)
    self.result = new_result
    calculate
  end

  def calculate
    if self.result
      player_one.send(:played, self)
      player_two.send(:played, self)
      save
    end
    self
  end

	# Player +:one+ has won!
	# This is a shortcut method for setting the score to 1
  def win
    process_result 1.0
  end

	# Player +:one+ has lost!
	# This is a shortcut method for setting the score to 0
  def lose
    process_result 0.0
  end

	# It was a draw.
	# This is a shortcut method for setting the score to 0.5
  def draw
    process_result 0.5
  end


	# Set the winner. Provide it with a Elo::Player. 
  def winner=(player)
    process_result(player == player_one ? 1.0 : 0.0)
  end

	# Set the loser. Provide it with a Elo::Player. 
  def loser=(player)
    process_result(player == player_one ? 0.0 : 1.0)
  end

	# Access the Elo::Rating objects for both players.
  def ratings
    @ratings ||= { player_one => rating_one, player_two => rating_two }
  end


  private

	# Create an Elo::Rating object for player one
  def rating_one
    Elo::Rating.new(:result        => self.result,
               :old_rating    => player_one.rating,
               :other_rating  => player_two.rating,
               :k_factor      => player_one.k_factor)
  end

	# Create an Elo::Rating object for player two
  def rating_two
    Elo::Rating.new(:result        => (1.0 - self.result),
               :old_rating    => player_two.rating,
               :other_rating  => player_one.rating,
               :k_factor      => player_two.k_factor)
  end
  
  
end