# deals with the input/output of the blackJack game
trap("SIGINT") { throw :quit }

class InputOutput
  def initialize
    @players = 0
  end

 # This method displays a welcome message.
  def welcome_msg
    puts
    puts "Welcome to BlackJack (by Luis Perez)!"
    puts "For instructions, press i."
    puts "To quit, press q."
    puts
  end

  def instructions
    puts 
    puts "For instructions, press i."
    puts "For statistics on current game, place m"
    puts "To quit, press q."
    puts
    puts "These are the actions you can perform on each hand:"
    puts " [h]it => press h"
    puts " [s]tand => press s"
    puts " [d]ouble => press d"
    puts " s[p]lit => press p"
    puts
    puts "Have Fun!!"
    puts
    puts
  end

  def start_round(game,round)
    self.display("\n\n\n\n-------Game #{game}, Round #{round}------\n")
  end

  # displays the blackjack deck (used for debugging purposes
  def show_deck(deck) 
    self.display(deck.to_s)
  end

  # Prompts the user for a bet between min and max
  def prompt_bet(player,min,max,step)
    def valid_bet(x)
      lambda {return x.to_i >= min && x.to_i < max && player.cash >= x.to_i}
    end
    return promptFunction("#{player.name}, what is your initial bet? [#{min}...#{max}] by #{step}? [#{min}]",
                          min, method(:valid_bet)).to_i
  end

  # Prompts the user for an integer > 0. Empty entry returns default.
  def prompt_positive(msg, default)
    def positive(x)
      return x.to_i > 0
    end
    return promptFunction(msg, default, method(:positive)).to_i
  end

  # returns true on conformation of message, false otherwise
  def prompt_yes_no(msg, default)
    def yes_no(x)
      return (x.downcase == "y" || x.downcase == "yes" ||
        x.downcase == "n" || x.downcase == "no")
    end
    return promptFunction(msg, default, method(:yes_no)).chars.first == "y"
  end

  # Prompts for a message until the result satisfies the given function
  def promptFunction(msg, default, function)
    result = nil
    while not result
      result = prompt(msg,default)
      if !function.call(result)
        result = nil
        self.retry
      end 
    end
    return result
  end

  # Prompts the user for a simple msg. On empty entry, returns default.
  def prompt(msg, default)
    result = nil
    while not result 
      puts "#{msg}"
      result = gets.strip
      if result.downcase == "q"
        throw :quit
      elsif result.downcase == "i"
        result = nil
        self.instructions
      elsif result == ""
        return default
      else 
        return result 
      end
    end
    return result
  end

  # displays the endgame statistics
  def show_stats(players, rounds, games)
    for player in players
      puts player.to_s
    end

    puts "You completed #{games} complete games"
    puts "   and #{rounds} rounds in the final game."
  end

  # display a simple message to the user
  def display(msg)
    puts msg
  end

  # retrieves the move selection from the suers and returns it to the string
  # in any format you'd like
  def get_move
    result = nil
    while not result
      result = self.prompt("What would you like to do? [h]:", "h")
    end
    return result
  end

  # Shows the hands of the players passed as inputs
  def show_hands(players)
    for player in players
      for hand in player.hands
        puts "#{player.to_s} #{hand.to_s}"
      end
    end
  end

  def retry
    puts "Please try again!"
  end
end
