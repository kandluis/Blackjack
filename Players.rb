# Player Class
#
# => Implements a (blackjack) card game player
# => Properties
#   => .cash = total cash on hand for betting
#   => . 
#

require Cards

class Player

  attr_accessor :name, :cash, :bet

  # @@ implies this is a class variable
  @@total_cash = 0
  @@total_hands = 0

  # New player with no hands, name name, and available cash cash
  def initialize(name, cash)
    @name = name
    @cash = cash
    @bet = 0
    @hands = []

    # update globals
    @@cash += @cash
  end

  # Returns Name: Hands (bet) [cash]
  def to_s
    return "#{@name}: #{@hands.length} hand (#{@bet.to_s}) [#{@cash.to_s}]"
  end

  # access to total cash
  def all_cash
    return @@total_cash
  end

  # adds a new hand to the player
  def add_hand(hand)
    @@total_hands += 1
    @hands.append(hand)
    return @hands[-1]
  end

  # places the bet on the specified hand. The hand must belong to the player and
  # the player must have enough cash to make the bet
  def place_bet(hand,bet)
    if @hands.include?(hand) && @cash - bet >= 0
      hand.bet = bet
      @cash -= bet
      @@total_cash -= bet
    else
      return false
    end
  end

  # double bet on the specified hand, returns false if not enough cash
  def double_bet(hand)
    if @cash - hand.bet > 0
      @cash -= hand.bet
      @@cash -= hand.bet
      hand.double_bet
      return true
    else
      return false
  end

  # splits the specified hand into two hands if possible
  # returns true on success, false if not enough cash
  def split_hand(hand)
    if hand.split?
      if @cash - hand.bet >= 0
        @@total_hands += 1
        @hands.append(hand.split)
        @cash -= hand.bet
        @@cash -= hand.bet
        return true
      else
        return false
      end
    else
      raise ArgumentError, "Hand cannot be split: #{hand.to_s}"
    end
  end

  # called at start of a round to throw away old hands
  def start_new_round:
    @hands = []
  end
  
  # call so player stands on all hands
  def end_round
    @hands.each{ |hand| hand.stand }
  end

  # adds winnings to player
  def won_bet(winnings)
    @@total_cash += winnings
    @cash += winnings
  end

  # returns true of the player has live hands
  def has_hands
    return @hands.select{|hands| hands.status == HandStatus::PLAY} != []
  end

  def total_hands
    return @@total_hands
  end



end
