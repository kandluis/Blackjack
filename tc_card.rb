####
# Test cases for the class definitions in bj_card.rb 
#
# Author: Luis Perez
# Last modified: January 13, 2015
###

require 'test/unit'
require 'bj_card'

class CardTest < Test::Unit::TestCase
  # create test card (Ace of Diamonds) and K of Spades
  def setup
    @cardA = Card.new("A", "D")
    @card = Card.new("K", "S")
  end

  def test_valid
    assert(@cardA.is_valid)
    assert(@card.is_valid)
  end

  # card is an ace
  def test_ace
    assert(@cardA.ace?, "Ace validation")
    assert(!@card.ace?, "Ace invalidation")
  end

  # ace should have two possible values
  def test_value 
    assert_equal(2, @cardA.all_values.length, "Ace is double valued")
    assert_equal(1, @card.all_values.length, "Other cards are single valued")
  end

  def test_strings
    puts
    puts "Testing card conversion to string."
    puts "Ace of Diamonds is first, then King of Spades. Both in short and long format."
    puts @cardA.to_s
    puts @cardA.to_long_s
    puts
    puts @card.to_s
    puts @card.to_long_s
    puts

    # to make sure printing occurred
    assert(true)
  end
end
