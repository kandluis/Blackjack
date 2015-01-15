# Player Class
#
# => Implements a (blackjack) card game player
# => Properties
#   => .name = name of th player
#   => .cash = total cash on hand for betting
#   => .hand = array of hands available to player 

require 'bj_card'

class Player

  attr_accessor :name, :cash, :bet, :total_bet, :hands

  # you can only split up to three times
  MAX_SPLITS = 3

  # New player with no hands, name name, && available cash cash
  def initialize(name, cash)
    @name = name
    @cash = cash
    @hands = []
    @bet = 0 # amount of money player is betting on default hand
    @total_bet = 0 # total amount bet on all hands thus far

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
      @total_bet += hand.bet
      @cash -= @bet
      return true
    else
      return false
    end
  end

  # double bet on the specified hand, returns false if not enough cash or not owner
  # of the hand
  def double_bet(hand)
    if double_bet?(hand)
      @cash -= hand.bet
      @total_bet += hand.bet
      hand.double_bet
      return true
    else
      return false
    end
  end

  # can the player double his bet on the specified hand?
  def double_bet?(hand)
    return @hands.include?(hand) && hand.double? && @cash - hand.bet >= 0
  end

  # adds winnings to player
  def won_bet(winnings)
    @cash += winnings
  end

  # splits the specified hand into two hands if possible
  # returns the new hand or nil 
  def split_hand(hand)
    if split_hand?(hand)
      new_hand = hand.split
      @hands << new_hand
      @cash -= hand.bet
      @total_bet += hand.bet
      return new_hand
    else
      return nil
    end
  end

  # can the player split the specified hand?
  def split_hand?(hand)
    return @hands.include?(hand) && hand.split? && @hands.length <= MAX_SPLITS && @cash - hand.bet >= 0
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

