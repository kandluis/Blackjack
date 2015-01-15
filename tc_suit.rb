require 'test/unit'
require 'bj_suit'

class CardSuitsTest < Test::Unit::TestCase
  # setup suits
  def setup
    @suits = CardSuits.new
  end

  # test size 
  def test_counts
    assert_equal(4, @suits.length, "Four suits")
    assert_equal(4, @suits.uniq.length, "Suits unique")
  end
end
