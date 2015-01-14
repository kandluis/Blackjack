require 'test/unit'
require 'Cards'
require 'Players'
require 'InputOutput'

class TestIO < Test::Unit::TestCase
  # setup test cases
  def setup
    @io = InputOutput.new
    @cash = 1000
    @players = [Player.new("Test", @cash), Player.new("Test2", @cash)]
  end

  def test_messages
    puts 
    puts "Testing static messages."
    puts
    puts @io.welcome_msg
    puts @io.instructions
    puts
    puts "Testing start round message with random input."
    puts @io.start_new_round(0,0)

  end
end
