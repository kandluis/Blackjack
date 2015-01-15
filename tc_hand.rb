require 'test/unit'
require 'bj_hand'

class HandTest < Test::Unit::TestCase
  def setup
    # corresponding keys in below hashes should be used in conjunction
    # could have made into a two-level hash, but the below made testing easier
    @hands = Hash['bj', Hand.new, 'bust', Hand.new, 'hit', Hand.new]
    @cards = Hash['bj', [Card.new("A", "D"), Card.new("K", "D")], 
      'bust', [Card.new("K", "D"), Card.new("Q", "D"), Card.new("J", "D")],
      'hit', [Card.new("2", "D")]]
    @values = Hash['bj', 21, 'bust', 0, 'hit', 2]

    # add cards to decks
    @hands.each{|key, hand| 
      @cards[key].each{|card| 
        hand.hit(card)
      }
    }
  end

  # test setup occurred correctly
  def test_setup
    # assure hands are playable
    @hands.each{|key, hand| assert_equal(HandStatus::PLAY, hand.status, "Hand Status")}
    
    # assert lengths
    @hands.each{|key, hand|
      assert_equal(@cards[key].length, hand.cards.length)
    }

  end

  # test hand is correct value
  def test_values    
    # test values match up
    @hands.each{|key, hand|
      assert_equal(@values[key], hand.max_hand, "Hand value")
      
      # .hit?, .bust?, .bj? work
      assert(key != "hit" || hand.hit?)
      assert(key != "bust" || hand.bust?)
      assert(key != "bj" || hand.bj?)
    }
    end

  # test betting functionality
  def test_bet
    @hands.each{|key, hand|
      hand.bet = 10
      hand.double_bet
      # this is MAKING THE ASSUMPTION that the hand has two cards!
      if hand.size == 2
        assert_equal(20, hand.bet, "double bet succeeded")
      else
        assert_equal(10, hand.bet, "double bet failed")
      end
    }
  end

  # test hand enters stand status
  def test_status
    @hands.each{|key, hand|       
      # change status of hand
      hand.stand
      assert_equal(HandStatus::STAND, hand.status)
    }
  end

  # testing ability to split a hand
  def test_split_and_double
    hand = Hand.new
    hand.hit(Card.new("A","D"))
    hand.hit(Card.new("A","S"))
    # place a bet
    hand.bet = 100

    # can you split?, are you an ace
    assert(hand.split? && hand.has_aces? && hand.size == 2)

    # split them and make sure split properties are all satisfied
    new_hand = hand.split()
    assert_equal(1, hand.size, "Number of cards after split")
    assert_equal(1, new_hand.size, "Number of cards after split")
    assert(hand.has_aces? && new_hand.has_aces?, "Correct cards split")
    assert(!hand.split? && !new_hand.split?, "Hands can no longer be split")
    assert_equal(100, new_hand.bet, "Bet duplicated")
    assert_equal(100, hand.bet, "Bet remains")

    # now, double the bets
    assert(!new_hand.double?, "Cannot double bet on a single card")
    new_hand.hit(Card.new("K","D"))
    assert(new_hand.double_bet)
    assert_equal(hand.bet*2, new_hand.bet)
  end

  # test printability
  def test_string
    puts "Test hand conversion to string."
    puts "Multiple hands of each type: busted, playable, blackjack."
    puts 
    @hands.each{ |key, hand| puts hand.to_s }
    puts
  end
end
