require 'test/unit'
require 'Cards'

class SymbolValsTest < Test::Unit::TestCase
  # setup the hash table
  def setup
    @symbols = SymbolVals.new
  end

  # Check correct number of symbols
  def test_counts
    assert_equal(14, @symbols.length, "Symbols Length")
  end

  # Check values match restrictions
  def test_values
    assert_equal(9, @symbols.select{ |key, value| value < 10}.length, "Low Value Cards")
    assert_equal(4, @symbols.select{ |key, value| value == 10}.length, "Face Cards")
    assert_equal(1, @symbols.select{|key, value| value == 1}.length, "Ace as 11")
  end
end

class CardSuitsTest < Test::Unit::TestCase
  # setup suits
  def setup
    @suits = CardSuits.new
  end

  # test size 
  def test_counts
    assert_equal(4, @suits.length, "Four suits")
    assert_equal(4, @suits.uniq.length, "Suits unique")
  end
end

class CardTest < Test::Unit::TestCase
  # create test card (Ace of Diamonds) and K of Spades
  def setup
    @cardA = Card.new("A", "D")
    @card = Card.new("K", "S")
  end

  # card is an ace
  def test_ace
    assert(@cardA.ace?, "Ace validation")
    assert(!@card.ace?, "Ace invalidation")
  end

  # ace should have two possible values
  def test_value 
    assert_equal(2, @cardA.all_values.length, "Ace is double valued")
    assert_equal(1, @card.all_values.length, "Other cards are single valued")
  end
end

class DeckTest < Test::Unit::TestCase
  # setup test deck
  def setup
    @numMultiDecks = 3
    @deck = Decks.new(1)
    @deckMulti = Decks.new(@numMultiDecks)
  end

  # test basic facts about decks
  def test_simple
    assert_equal(52, @deck.cards.length, "Single deck length")
    assert_equal(52 * @numMultiDecks, @deckMulti.cards.length, "Multiple decks length")
  end

  # Check the shuffled deck @numMultiDecks times.
  def test_deck_shuffle
    1.upto(@numMultiDecks) do |x|
      @deck.shuffle
      assert_equal(52, @deck.cards.length, "Deck shuffle")
      assert_equal(52 * @numMultiDecks, @deckMulti.cards.length, "Multiple deck shuffle")
    end
  end
end

class HandTest < Test::Unit::TestCase
  def setup
    @hands = Hash['bj', Hand.new, 'bust', Hand.new, 'hit', Hand.new]
    @cards = Hash['bj', [Card.new("A", "D"), Card.new("K", "D")], 
      'bust', [Card.new("K", "D"), Card.new("Q", "D"), Card.new("J", "D")],
      'hit', [Card.new("2", "D")]]
    @values = Hash['bj', 21, 'bust', 0, 'hit', 2]
  end

  # test setup occurred correctly
  def test_setup
    @hands.each{|key, hand| assert_equal(HandStatus::PLAY, hand.status, "Hand Status")}
    # add cards to decks
    @hands.each{|key, hand| 
      @cards[key].each{|card| 
        hand.hit(card)
      }
    }
    # assert lengths
    @hands.each{|key, hand|
      assert_equal(@cards[key].length, hand.cards.length)
    }

  end

  # test hand is correct value
  def test_values
    # add cards to decks
    @hands.each{|key, hand| 
      @cards[key].each{|card| 
        hand.hit(card)
      }
    }
    
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
      assert_equal(20, hand.bet)
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
end


