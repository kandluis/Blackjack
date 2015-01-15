require 'bj_symbol'
require 'bj_suit'
require 'bj_hand'

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
  attr_accessor :bet, :state, :status, :ace_split, :is_split

  # need only read access
  attr_reader :cards

  @@cardSuits = CardSuits.new
  @@symbolVals = SymbolVals.new

  def initialize
    @bet = 0
    @status = HandStatus::PLAY
    @cards = []
    @ace_split = false
    @is_split = false

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
    return self.max_hand == BJ_HAND && !@ace_split
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
      # keep track of whether the hand has been split before
      @ace_split = true if has_aces?
      @is_split = true
      hand = Hand.new
      hand.ace_split = @ace_split
      hand.is_split = @is_split
      hand.hit(@cards.slice!(1))
      hand.bet = @bet
      return hand
    else
      return nil
    end
  end

  # Can this hand be split?
  def split?
    return @cards.length == 2 && @cards[0].symbol == @cards[1].symbol
  end

  # You can double down only after looking at your first two cards on a hand 
  # You cannot take a hit && double down. For more, see 
  # https://www.cs.bu.edu/~hwxi/academic/courses/CS320/Spring02/assignments/06/blackjack.html
  # However, you CAN double down after splitting and receiving a hit
  def double?
    return @cards.length == 2 && !@is_split
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
