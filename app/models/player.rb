require 'elo'

class Player < ActiveRecord::Base
  
  has_many :games, :finder_sql => 'SELECT * FROM games WHERE (games.player_one_id = #{self.id} OR games.player_two_id = #{self.id})'
  
  has_many :victories, :class_name => 'Game', 
            :finder_sql => 'SELECT * FROM games WHERE ((games.player_one_id = #{self.id} AND result >= 1) OR 
                                                      (games.player_two_id = #{self.id} AND result = 0))'
                                                      
  has_many :defeats, :class_name => 'Game', 
            :finder_sql => 'SELECT * FROM games WHERE ((games.player_one_id = #{self.id} AND result = 0) OR 
                                                      (games.player_two_id = #{self.id} AND result >= 1))'
  
  # The rating you provided, or the default rating from configuration
  # def rating
  #   @rating ||= Elo.config.default_rating
  # end

	# The number of games played is needed for calculating the K-factor.
  def games_played
    @games_played ||= games.size
  end
  
  # Is the player considered a pro, because his/her rating crossed
	# the threshold configured? This is needed for calculating the K-factor.
  def pro_rating?
    self.rating >= Elo.config.pro_rating_boundry
  end
  
  # Is the player just starting? Provide the boundry for
	# the amount of games played in the configuration.
	# This is needed for calculating the K-factor.
  def starter?
    games_played < Elo.config.starter_boundry
  end

	# FIDE regulations specify that once you reach a pro status
	# (see +pro_rating?+), you are considered a pro for life.
	#
	# You might need to specify it manually, when depending on
	# external persistence of players.
	#
	#		Elo::Player.new(:pro => true)
  def pro?
    !!@pro
  end
  
  
  # Calculates the K-factor for the player.
	# Elo allows you specify custom Rules (see Elo::Configuration).
	#
	# You can set it manually, if you wish:
	#
	#		Elo::Player.new(:k_factor => 10)
	#
	#	This stops this player from using the K-factor rules.
  def k_factor
    return @k_factor if @k_factor
    Elo.config.applied_k_factors.each do |rule|
      return rule[:factor] if instance_eval(&rule[:rule])
    end
    Elo.config.default_k_factor
  end
  
  
  # Start a game with another player. At this point, no
	# result is known and nothing really happens.
  def versus(other_player, options = {})
    Game.new(options.merge(:player_one => self, :player_two => other_player)).calculate
  end

	# Start a game with another player and set the score
	# immediately.
  def wins_from(other_player, options = {})
    versus(other_player, options).win
  end

	# Start a game with another player and set the score
	# immediately.
  def plays_draw(other_player, options = {})
    versus(other_player, options).draw
  end

	# Start a game with another player and set the score
	# immediately.
  def loses_from(other_player, options = {})
    versus(other_player, options).lose
  end
  
  
  private

  # A Game tells the players informed to update their
  # scores, after it knows the result (so it can calculate the rating).
  #
  # This method is private, because it is called automatically.
  # Therefore it is not part of the public API of Elo.
  def played(game)
    games << game
    self.rating = game.ratings[self].new_rating
    @pro    = true if pro_rating?
    save
  end
  
  
end
