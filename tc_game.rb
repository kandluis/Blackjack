require 'test/unit'
require 'bj_game'

class TestGame < Test::Unit::TestCase
  def setup
    @game = Game.new
  end

  def test_play
    puts "To test the game class, simply play the game by running"
    puts "  ruby bj_play.rb --debug"
    puts @game
  end
end
