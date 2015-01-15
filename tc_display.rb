require 'test/unit'
require 'bj_deck'
require 'bj_player'
require 'bj_display'

class TestIO < Test::Unit::TestCase
  # setup test cases
  def setup
    @io = Display.new
    @cash = 1000
    @max = 1000 # largest integer value used for testing
    @players = [Player.new("Test", @cash), Player.new("Test2", @cash)]
    
    # each player will have a single hand with an ace of diamonds
    @players.each{ |player| 
      hand = Hand.new
      hand.hit(Card.new("A", "D"))
      player.add_hand(hand)
    }

    # could redefine the prompt function here
  end

  def test_messages
    puts 
    puts "Testing static messages."
    puts
    @io.welcome_msg
    @io.instructions
    @io.player_bj
    @io.player_tie(@players[0])
    @io.player_lose(@players[0])
    @io.player_win_bj(@players[0])
    @io.player_win(@players[0])
    @io.out_of_cards
    @io.finish_round
    @io.retry
    puts
    puts "Testing start round message with random input."
    puts @io.start_round(rand(@max),rand(@max))
    puts
    puts "Testing show functions with random inputs."
    @io.show_deck(Decks.new(1))
    puts
    @io.show_stats(@players, [], rand(@max), rand(@max))
    puts
    @io.show_hands(@players)
    puts
    @io.show_card(@players[0], 0, 0)
    puts 
    puts "Need to manually test the following methods - they require user input."
    puts ":Display.get_move(player, hand)"
    puts ":Display.get_shoe_size"
    puts ":Display.get_default_cash(curr_cash)"
    puts ":Display.get_num_players"
    puts ":Display.get_player_name(name)"
    puts ":Display.get_bet(player, min, max, step)"
    puts
  end
end
