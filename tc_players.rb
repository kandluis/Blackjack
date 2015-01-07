require 'test/unit'
require 'Cards'
require 'Players'

class TestPlayer < Test::Unit::TestCase
  # testing player
  def setup
    @cash = 1000
    @hand = Hand.new
    @player = Player.new("Test", @cash)
  end

  # testing defaults of player class
  def test_simple
    assert(!@player.has_hands)
    assert(!@player.main_hand)

    # add a hand
    @player.add_hand(@hand)
    assert(@player.has_hands)
  end

  # testing ability to place bets
  def test_bet
    @player.add_hand(@hand)

    bet = @cash + 1
    @player.bet = bet
    assert(!@player.place_bet(@hand), "Not enough cash")
    
    @player.bet = @cash
    assert(!@player.place_bet(Hand.new), "Not owner of hand")
  
    bet = @cash/2 + 1
    @player.bet = bet
    assert(@player.place_bet(@hand), "Placed bet")
    assert_equal(@cash - bet, @player.cash, "Cash discounted")
    assert(!@player.double_bet(@hand), "Not enough cash to double")

    @player.won_bet(@player.bet)
    assert(@player.cash == @cash)

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
end
