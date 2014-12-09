# deals with the input/output of the blackJack game
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
    return promptFunction(msg, default, method(:yes_no))[0] == "y"
  end

  # Prompts for a message until the result satisfies the given function
  def promptFunction(msg, default, function)
    result = nil
    while not result
      result = prompt(msg,default)
      if function.call(msg)
        result = nil
        self.try_again
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

    puts "Total cash: #{players[0].all_cash}."
    puts "You completed #{games - 1} complete games"
    puts "   and #{rounds} rounds in the final game."
  end

  # display a simple message to the user
  def display(msg)
    puts msg
  end

  def try_again
    puts "Please try again!"
  end
end
