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

  # @@ implies this is a class variable
  @@total_cash = 0
  @@total_hands = 0

  # New player with no hands, name name, and available cash cash
  def initialize(name, cash)
    @name = name
    @cash = cash
    @hands = []
    @bet = 0

    # update globals
    @@total_cash += @cash
  end

  # adds a new hand to the player
  def add_hand(hand)
    @@total_hands += 1
    @hands << hand
    return @hands[-1]
  end

  # returns true if the player has live hands
  def has_hands
    return @hands.select{|hands| hands.status == HandStatus::PLAY} != []
  end

  def total_hands
    return @@total_hands
  end

  # access to total cash
  def all_cash
    return @@total_cash
  end

  # places the bet on the specified hand. The hand must belong to the player and
  # the player must have enough cash to make the bet
  def place_bet(hand)
    if @hands.include?(hand) && @cash - @bet >= 0
      hand.bet = @bet
      @cash -= @bet
      @@total_cash -= @bet
      return true
    else
      return false
    end
  end

  # double bet on the specified hand, returns false if not enough cash
  def double_bet(hand)
    if @cash - hand.bet > 0
      @cash -= hand.bet
      @@total_cash -= hand.bet
      hand.double_bet
      @bet *= 2
      return true
    else
      return false
    end
  end

  # adds winnings to player
  def won_bet(winnings)
    @@total_cash += winnings
    @cash += winnings
  end

  # splits the specified hand into two hands if possible
  # returns true on success, false if not enough cash
  def split_hand(hand)
    if hand.split?
      if @cash - hand.bet >= 0
        @@total_hands += 1
        @hands << hand.split
        @bet *= 2
        @cash -= hand.bet
        @@total_cash -= hand.bet
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
