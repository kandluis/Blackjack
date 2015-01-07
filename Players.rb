# Player Class
#
# => Implements a (blackjack) card game player
# => Properties
#   => .name = name of th player
#   => .cash = total cash on hand for betting
#   => .hand = array of hands available to player 

require 'Cards'

class Player

  attr_accessor :name, :cash, :bet, :hands

  # New player with no hands, name name, and available cash cash
  def initialize(name, cash)
    @name = name
    @cash = cash
    @hands = []
    @bet = 0

  end

  # adds a new hand to the player return the just added hand
  def add_hand(hand)
    @hands << hand
    return @hands[-1]
  end

  # returns true if the player has live hands
  def has_hands
    return @hands.select{|hands| hands.status == HandStatus::PLAY} != []
  end

  # return zero-indexed hand if available (primarily used by the dealer)
  def main_hand
    if has_hands
      return @hands[0]
    else
      return false
    end
  end

  # places the bet on the specified hand. The hand must belong to the player and
  # the player must have enough cash to make the bet
  def place_bet(hand)
    if @hands.include?(hand) && @cash - @bet >= 0
      hand.bet = @bet
      @cash -= @bet
      return true
    else
      return false
    end
  end

  # double bet on the specified hand, returns false if not enough cash or not owner
  # of the hand
  def double_bet(hand)
    if @hands.include?(hand) && @cash - hand.bet > 0
      @cash -= hand.bet
      hand.double_bet
      @bet *= 2
      return true
    else
      return false
    end
  end

  # adds winnings to player
  def won_bet(winnings)
    @cash += winnings
  end

  # splits the specified hand into two hands if possible
  # returns true on success, false if not enough cash
  def split_hand(hand)
    if hand.split?
      if @cash - hand.bet >= 0
        @hands << hand.split
        @bet *= 2
        @cash -= hand.bet
        return true
      else
        return false
      end
    else
      return false
    end
  end

  # called at start of a round to throw away old hands
  def start_new_round
    @hands = []
  end
  
  # call so player stands on all hands
  def end_round
    @hands.each{ |hand| hand.stand }
  end

  # Returns Name: Hands [cash]
  def to_s
    return "#{@name}: #{@hands.length} hand(s) [Cash: #{@cash.to_s}]"
  end

end

