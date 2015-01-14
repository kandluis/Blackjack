require 'test/unit'
require 'Cards'
require 'Players'

class TestPlayer < Test::Unit::TestCase
  # testing player
  def setup
    @cash = 1000
    @hand = Hand.new
    @hand.hit(Card.new("A","D"))
    @hand.hit(Card.new("A","S"))
    @player = Player.new("Test", @cash)
    @player.add_hand(@hand)
  end

  # testing defaults of player class
  def test_simple
    assert(@player.has_hands)
    assert(@player.main_hand)
  end

  # testing ability to place bets
  def test_bet
    # error if not enough cash
    bet = @cash + 1
    @player.bet = bet
    assert(!@player.place_bet(@hand), "Not enough cash")
    
    # error if hand is not in player's possession
    @player.bet = @cash
    assert(!@player.place_bet(Hand.new), "Not owner of hand")
  
    # workable bet, but not enough to double
    bet = @cash/2 + 1
    @player.bet = bet
    assert(@player.place_bet(@hand), "Placed bet")
    assert_equal(@cash - bet, @player.cash, "Cash discounted")
    assert(!@player.double_bet(@hand), "Not enough cash to double")

    # player wins
    @player.won_bet(@player.bet)
    assert(@player.cash == @cash)

    # player bets enough to double later
    bet = @cash/2 - 1
    @player.bet = bet
    @player.place_bet(@hand)
    assert(!@player.double_bet(Hand.new), "Does not own hand to double")

    assert(@player.double_bet(@hand), "Doubled bet")
    assert_equal(@cash - 2*bet, @player.cash, "Double bet cash discounted")
  end

  # testing ability to start a new round
  def test_new_round
    # end the round by making finishing all hands
    @player.end_round
    @player.hands.each{|hand|
      assert(!hand.hit?)
    }
  
    # start a new round
    @player.start_new_round
    assert_equal([], @player.hands, "New Round Hands")
  end

  # test ability for player to split his hand
  def test_split_hand
    @player.bet = @cash/2 - 1

    # add hand to player and split it
    @player.place_bet(@hand)

    assert(@player.split_hand(@hand), "Hand Split success")

    # verify the hands have been split and the player cash is correct
    assert_equal(@cash - 2*@player.bet, @player.cash, "Player cash after split")
    assert_equal(2, @player.hands.length, "Correct number of player hands after split")

    # verify the bets on the hands
    @player.hands.each{ |hand| assert_equal(@player.bet, hand.bet)}

  end

  # testing pritability of player information
  def test_strings
    puts
    puts "Testing player class for string representation"
    puts
    puts @player.to_s
    puts

    # make sure we get here
    assert(true)
  end
end
