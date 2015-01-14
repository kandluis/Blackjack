# IO Class
#
# => Implements the input/output functionality for a blackjack game.
#    Used so we can abstract the input/output functionality. Currently implements
#    A simple terminal based game.
# => Properties
#   => .players = number of players playing the blackjack game

# deals with the input/output of the blackJack game
trap("SIGINT") { throw :quit }

# access to Decks constants
require 'Cards'

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
    puts "For statistics on current game, press m"
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
    display("\n\n\n\n-------Game #{game}, Round #{round}------\n")
  end

  # displays the blackjack deck (used for debugging purposes
  def show_deck(deck) 
    display(deck.to_s)
  end

  # displays the endgame statistics
  def show_stats(players, rounds, games)
    for player in players
      puts player.to_s
    end

    puts "You completed #{games} complete games"
    puts "   && #{rounds} rounds in the final game."
  end

  # Shows the hands of the players passed as inputs
  def show_hands(players)
    for player in players
      for hand in player.hands
        puts "#{player.to_s} ------ #{hand.to_s}"
      end
    end
  end

  # Shows the j-th card in the i-th hand of the given player
  def show_card(player, i, j)
    display("#{player.name} has: #{player.hands[i].cards[j]}\n\n")
  end

  # Shows the player && his hand
  def show_hand(player, hand)
    display("#{player.name} has hand: #{hand.to_s}.")
  end

  # retrieves the move selection from the suers && returns it to the string
  # in any format you'd like
  def get_move(player, hand)
    # tell the player what we can do
    puts
    puts "You can [h]it"
    puts "or [s]tand" unless !hand.stand?
    puts "or [d]ouble down" unless !hand.double?
    puts "or s[p]lit" unless !hand.split?
    puts 

    # now prompt the player
    result = nil
    while not result
      result = prompt("What would you like to do? [h]:", "h")
    end
    return result
  end

  # retrieves the number of decks in the shoe for this blackjack game instance
  def get_shoe_size
    return prompt_positive_integer("Number of decks at table? [#{Decks::MIN_DECKS}]", Decks::MIN_DECKS)
  end

  # retrieves default value of cash to be used for each starting player
  def get_default_cash(curr_cash)
    return prompt_positive_integer("How much cash per player? [#{curr_cash}]", curr_cash)
  end

  # retrieves the number of players in the game
  def get_num_players
    return prompt_positive_integer("Number of players? [1]",1)
  end

  # retrieves the name of a single player
  def get_player_name(name)
    return prompt("Player Name? [Player #{name}]","Player #{name}")
  end

  # retrieves the user for a bet between min && max
  def get_bet(player,min,max,step)
    result = nil
    while not result 
      string = prompt("#{player.name}, what is your initial bet? [#{min}...#{max}] by #{step}? [#{min}]",
                      min)
      result = string.to_i
      if result < min or result > max or result > player.cash or result.to_s != string
        result = nil
        puts "Please try again!"
      end 
    end
    return result

    '''
    def valid_bet(x)
      lambda{ return(x.to_i >= min && x.to_i < max && player.cash >= x.to_i) }
    end
    return promptFunction("#{player.name}, what is your initial bet? [#{min}...#{max}] by #{step}? [#{min}]",
                          min, valid_bet).to_i
    '''
  end

  # Shows messages prompting the user whether or not he wishes to start a new 
  # blackjack game
  def continue_play?(game_num)
    return prompt_yes_no("Would you like to continue playing? [no]\n This will be game #{game_num}", "no")
  end

  # Messages for the user when he/she wins/ties/loses
  
  def player_bj
    display("Nice job with the BJ! Let's stay put.")
  end
  def player_tie(player)
    display("Oh, darn! #{player.name} doesn't get anything that round! Now at $#{player.cash}.")
  end
  def player_lose(player)
    display("Looks like the dealer got this one! #{player.name} is left with $#{player.cash}")
  end
  def player_win_bj(player)
    display("CONGRATULATIONS! #{player.name} now has $#{player.cash}!")
  end
  def player_win(player)
    display("A normal win. Now #{player.name} has $#{player.cash}")
  end

  # Shoe no longer contains cards
  def out_of_cards
    display("---Dealer ran out of cards this round!---\n\n")
  end

  # Message displayed when the round is about to be settled
  def finish_round
    display("\n\n ---------------- TIME TO SETTLE ---------------- \n\n")
  end

  def retry
    puts "Please try again!"
  end

  ##### HELPER FUNCTIONS - Do not access outside of class ######
  private # declares all methods below as private

  # Prompts the user for an integer > 0. Empty entry returns default.
  def prompt_positive_integer(msg, default)
    def positive(x)
      return x.to_i > 0 && x.to_i.to_s == x
    end
    return promptFunction(msg, default, method(:positive)).to_i
  end

  # returns true on conformation of message, false otherwise
  def prompt_yes_no(msg, default)
    def yes_no(x)
      return (x.downcase == "y" or x.downcase == "yes" or
        x.downcase == "n" or x.downcase == "no")
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
        puts "Please try again!"
      end 
    end
    return result
  end

  # Prompts the user for a simple msg. On empty entry, returns default.
  def prompt(msg, default)
    result = nil
    while not result
      display(msg)
      result = gets.strip
      if result.downcase == "q"
        throw :quit
      elsif result.downcase == "i"
        result = nil
        instructions
      elsif result == ""
        return default.to_s
      else 
        return result 
      end
    end
    return result
  end

  # display a simple message to the user
  def display(msg)
    puts
    puts msg
  end

end
