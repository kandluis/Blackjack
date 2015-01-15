# Map between numerical value and symbol of a blackjack card.

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
