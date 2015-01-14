###
# Cards.rb
# => Contains classes dealing directly with cards:
#    Card - a single card object
#    Hand - a single hand of cards
#    Decks - a generalized class which allows for a collection of decks (used
#             for the shoe)
###

# Map for keeping the value of each possible symbol on a card

# NOTE - in ruby, EVERYTHING is an object
class SymbolVals < Hash
  def initialize
    self["A"] = 1
    2.upto(9) do |value|
      self[value.to_s] = value
    end
    self["T"] = 10
    self["J"] = 10
    self["Q"] = 10
    self["K"] = 10

    # This is an A which we know to be worth 11 points
    self["AA"] = 11
  end
end

# List of possible suits (D)iamonds, (C)lubs, (H)earts, && (S)pades
class CardSuits < Array
  def initialize
    self[0] = "D"
    self[1] = "C"
    self[2] = "H"
    self[3] = "S"
  end
end

# A Card is either valid/invalid, consists of a symbol (A,2,...,10,J,Q,K)
# && belong to one of (D,C,H,S) suits
# Variables:
#  .suit
#  .symbol
# Methods:
#  .ace? -> if card can be multiple values (A can be 1 || 11)
#  .all_values -> array of all values card can have
#  .to_s -> 
class Card
  # mark readable attributes (should not be changed)
  attr_reader :symbol, :suit, :is_valid

  @@cardSuits = CardSuits.new
  @@symbolVals = SymbolVals.new

  def initialize(symbol, suit)
    if @@symbolVals.has_key?(symbol) && @@cardSuits.include?(suit)
      @suit = suit
      @symbol = symbol
      @is_valid = true
    else
      @is_valid = false
    end

    return self
  end

  # Method returns true if this card is a A
  def ace?
    return @symbol == "A"
  end

  # Returns an array of all values the card can take on
  def all_values
    values = [@@symbolVals[@symbol]]
    if self.ace?
      values.push(@@symbolVals["AA"])
    end    
    return values
  end

  # Returns text version of the card in format SYMBOL (SUIT)
  def to_s
    return "#@symbol(#@suit)"
  end

  # Returns text version of the card in format SYMBOL (SUIT) of VALUES
  # VALUES := VALUE || VALUES
  def to_long_s
    text = self.to_s + " of "
    values = self.all_values
    values_length = values.length
    values.each_with_index {|index, value| 
      text += "#{value}"
      text += (index != values_length - 1) ? "." : " or "
    } 

    return text
  end
end

# A typical card deck with 52 cards, four 13 card suits, with the 13 cards 
# as A,1,...,10,J,Q,K with 
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


# Enumerate possible types for a hand:
#   STAND - meaning the player has set this hand to stand until next round
#   PLAY - hand is still in play
#   BUST - hand has busted
class HandStatus
  STAND = 0
  PLAY = 1
end


# Keeps track of one hand for a player.
# Variables:
#   .bet
#   .status 
#   .cards
# Method:
#   .hit(card) - add card to this hand
#   .hit? - can this hand get a hit? 
#   .bust? - is this card a bust!? 
#   .bj? - is this a blackjack hand
#   .stand - we're done with the hand
#   .split - split the hand
#   .split? - can we split the hand?
#   .has_aces? - does the hand have at least one ace?
#   .total - array of possible acceptable values for this hand
#   .to_s - convert to string
class Hand
  # maximum value a hand can have before it is discarded
  BJ_HAND = 21

  # need to change these from the outside
  attr_accessor :bet, :state, :status

  # need only read access
  attr_reader :cards

  @@cardSuits = CardSuits.new
  @@symbolVals = SymbolVals.new

  def initialize
    @bet = 0
    @status = HandStatus::PLAY
    @cards = []

    return self
  end

  # returns the maximum value of the hand - call only if it is know that a hand exists
  def max_hand
    if self.total == []
      return 0
    end
    max = self.total[0]
    for value in self.total
      max = value < max ? max : value
    end
    return max
  end

  # Receives a hit (so adds a card) if the hand is in play status
  def hit(card)
    if @status == HandStatus::PLAY
      @cards[@cards.length] = card
      return true
    else
      return false
    end
  end

  # Can this hand be hit || has it already busted (or been set to stand)
  def hit?
    return self.total.select{|value| value <= BJ_HAND} != [] && @status != HandStatus::STAND
  end

  # Is this hand a bust?
  def bust?
    return self.total == []
  end

  # Is this hand a blackjack?
  def bj?
    return self.max_hand == BJ_HAND
  end

  # set the status of the hand to stand
  def stand
    @status = HandStatus::STAND
  end

  # Can the hand stand?
  def stand?
    return @status == HandStatus::PLAY
  end

  # splits the hand - updates the current hand, && returns the new one
  # returns nil if the hand cannot be split
  def split
    if self.split? 
      hand = Hand.new
      hand.hit(@cards.slice!(1))
      hand.bet = @bet
      return hand
    else
      return nil
    end
  end

  # Can this hand be split?
  def split?
    return @cards.length == 2 && @@symbolVals[@cards[0].symbol] == @@symbolVals[@cards[1].symbol]
  end

  # You can double down only after looking at your first two cards on a hand 
  # You cannot take a hit && double down. For more, see 
  # https://www.cs.bu.edu/~hwxi/academic/courses/CS320/Spring02/assignments/06/blackjack.html
  # However, you CAN double down after splitting and receiving a hit
  def double?
    return @cards.length == 2
  end
  
  # double bet on card
  def double_bet
    if double? 
      @bet *= 2
      return true
    else
      return false
    end
  end

  # Does the hand contain an A
  def has_aces?
    return (@cards.map {|card| card.symbol}).include?("A")
  end

  def size
    return @cards.length
  end

  # Return a list of values for this hand. It will return an empty list in the case
  # of an invalid hand (all possible values lead to a bust)

  # Could have implemented this more specific to blackjack, but wanted to keep the
  # BJ_HAND as general as possible
  def total
    return self.display_total.select{|value| value <= BJ_HAND}
  end

  def display_total
    values = [0]
    # for each card
    @cards.flatten!
    @cards.each{ |c| 
      # calculate concatenated list of possible values 
      updated_values = []
      c.all_values.each{|value| 
        updated_values += values.map{|prev_value| prev_value + value}
      }

      # remove all repeat values && those > BJ_HAND so we don't do unnecessary work later
      values = updated_values.uniq
    }

    return values
  end

  # generates string representing the hand as a [Card List] (Values) {Comment}
  def to_s
    comment = self.bust? ? "Done Busted!" : (self.bj? ? "BLACKJACK!" : "Keep it steady mate!")
    return "[#{@cards.map{|card| card.to_s }.join(", ")}] (#{self.display_total.join(" or ")}) {#{comment}}"
  end 
end 
