require 'bj_suit'
require 'bj_symbol'

# A Card is either valid/invalid, consists of a symbol (A,2,...,10,J,Q,K)
# and belongs to one of (D,C,H,S) suits. Symbols and suits are each specified
# in bj_symbol.rb and bj_suit.rb for more information.
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
