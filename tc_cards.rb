####
# Test cases for the class definitions in Cards.rb 
#
# Author: Luis Perez
# Last modified: January 13, 2015
###

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

  def test_valid
    assert(@cardA.is_valid)
    assert(@card.is_valid)
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

  def test_strings
    puts
    puts "Testing card conversion to string."
    puts "Ace of Diamonds is first, then King of Spades. Both in short and long format."
    puts @cardA.to_s
    puts @cardA.to_long_s
    puts
    puts @card.to_s
    puts @card.to_long_s
    puts

    # to make sure printing occurred
    assert(true)
  end
end

class DeckTest < Test::Unit::TestCase
  # setup test deck
  def setup
    @numMultiDecks = 3
    @deck = Decks.new(1)
    @deckMulti = Decks.new(@numMultiDecks)
  end

  # accessing attributes
  def test_setup
    assert_equal(1, @deck.num_decks)
    assert_equal(@numMultiDecks, @deckMulti.num_decks)
  end

  # test basic facts about decks
  def test_simple
    assert_equal(52, @deck.size, "Single deck length")
    assert_equal(52 * @numMultiDecks, @deckMulti.cards.length, "Multiple decks length")
  end

  # Check the shuffled deck @numMultiDecks times.
  def test_deck_shuffle
    1.upto(@numMultiDecks) do |x|
      @deck.shuffle
      assert_equal(52, @deck.size, "Deck shuffle")
      assert_equal(52 * @numMultiDecks, @deckMulti.cards.length, "Multiple deck shuffle")
    end
  end

  # testing the deal function which should return a card object until the deck is empty
  def test_deal
    1.upto(@deck.size) do |i|
      card = @deck.deal(1)
      if !card.is_a?(Card)
        puts card
      end
      cards = @deckMulti.deal(@numMultiDecks)
      assert_equal(@numMultiDecks, cards.length, "Deck can deal multiple cards at once")
      cards.each{ |c| assert(c.is_a?(Card), "Multideal deals all cards")}
    end

    # empty deck returns nil (TODO: could we raise an exception instead?)
    assert(@deck.size == 0 && @deck.deal(1) == nil, "Empty deck")
    assert(@deckMulti.cards.length == 0 && @deckMulti.deal(1) == nil, "Empty shoe")
  end

  # test the ability to add a card to the deck
  def test_add_card
    size = @deck.size
    @deck.add_card(Card.new("A","D"))
    assert_equal(size + 1, @deck.size)
  end

  def test_strings
    puts 
    puts "Testing deck conversion to string."
    puts "Full size, standard deck."
    puts 
    puts @deck.to_s
    puts
    puts "After a shuffle"
    puts

    @deck.shuffle

    puts @deck.to_s
    puts

    assert(true)
  end
end

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


