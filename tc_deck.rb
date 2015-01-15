require 'test/unit'
require 'bj_deck'

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
