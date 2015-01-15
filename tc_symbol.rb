require 'test/unit'
require 'bj_symbol'

class SymbolValsTest < Test::Unit::TestCase
  # setup the hash table
  def setup
    @symbols = SymbolVals.new
  end

  # Check correct number of symbols
  def test_counts
    assert_equal(14, @symbols.length, "Symbols Length")
  end

  # Check values match restrictions
  def test_values
    assert_equal(9, @symbols.select{ |key, value| value < 10}.length, "Low Value Cards")
    assert_equal(4, @symbols.select{ |key, value| value == 10}.length, "Face Cards")
    assert_equal(1, @symbols.select{|key, value| value == 1}.length, "Ace as 11")
  end
end
