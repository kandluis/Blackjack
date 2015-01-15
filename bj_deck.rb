require 'bj_suit'
require 'bj_symbol'
require 'bj_card'

# A typical card deck is defined as one with 52 cards, four 13 card suits, 
# with the 13 cards as A,1,...,10,J,Q,K with 
# Variables:
#  .num_decks = number of decks in this set of decks
#  .cards = the set of cards in the deck
# Methods:
#  .shuffle -> shuffles the deck of cards (original set is already shuffled)
#  .deal(num_cards) -> deals the specified number of cards from top of the deck
#  .add(card) -> adds card to the botton of deck
#  .to_s

class Decks

  # Class must have at least one deck
  MIN_DECKS = 1
  
  @@cardSuits = CardSuits.new
  @@symbolVals = SymbolVals.new
  
  attr_reader :num_decks, :cards

  def initialize(num_decks)
    @num_decks = num_decks
    @cards = []

    # at lest one deck
    if not @num_decks.is_a?(Integer) || @num_decks < MIN_DECKS
      raise ArgumentError, "Must have at least one deck."
    end

    # create the set of cards
    1.upto(@num_decks) do |i|
      @cards += self.createDeck
    end
    return self
  end

  # Creates a single array of cards representing a single, standard deck based on
  # the available suits && card symbols
  def createDeck
    deck = []
    for suit in @@cardSuits
      for symbol in @@symbolVals.keys
        if symbol != "AA"
            deck << Card.new(symbol, suit)
        end
      end
    end

    return deck
  end

  # Removes top num_cards of deck && returns those cards
  # Returns nil if no cards exist in the deck to fulfill the request
  def deal(num_cards)
    card_lst = @cards.slice!(0,num_cards)
    return (num_cards == 1 ? ((card_lst == nil) ? nil : card_lst[0]) : card_lst)
  end

  # Adds a new card to the bottom of the deck
  def add_card(card)
    @cards.push(card)
  end

  # Shuffles all cards in the deck (the .shuffle for arrays was not added until 
  # Ruby 1.9.1)
  def shuffle
    @cards.replace @cards.sort_by {rand}
  end

  # returns the size of the deck in terms of cards
  def size
    return @cards.length
  end

  # Converts deck to a string, with cards printed in current shuffled order
  def to_s
    text = "[#@num_decks deck" + ((@num_decks == 1) ? "" : "s") + " to start]\n"

    # assuming 4 characters per card, plus comma, plus space each card takes 
    # 6 characters. This gives a total of ~13 cards per line
    @cards.each_with_index.map { |c, i| 
      if i % 13 == 0
         text += "\n"
      else
        text += ", "
      end
      text += c.to_s
    }

    return text
  end

  # no need for this to be accessible outside class
  protected :createDeck
end
