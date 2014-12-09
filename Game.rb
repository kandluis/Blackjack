require 'InputOutput'
require 'Cards'
require 'Players'

class Game

  # Set debug to True to see dealer hands and game deck
  attr_accessor :debug

  # Game options (default starting cash for each player)
  attr_accessor :cash

  def initialize()
    @io = InputOutput.new
    @dealer, @deck = nil
    @num_rounds = 0
    @game_num = 1
    @cash = 1000
    @players = []
    @losers = []

    # using http://www.pagat.com/banking/blackjack.html as reference for the rules
    # of the blackjack game
    @min_bet = 5
    @max_bet = 100
  end

  # Main Function - plays the entire blackjack game:
  #   Get Input Parameters and Initialize Game
  #   While user wants to continue playing at the table
  #     Create table deck, shuffle deck
  #     While the deck has cards - players have money
  #       Place Bets -> Initial Deal -> Play Round -> Settle Round
  #     Done
  #   Done
  #   End Message
  #       
  def play
    started_round = false

    # if user quits, go ahead and still show end results
    catch :quit do
      self.start_game
      while self.continue_play?

        # play while we have cards and we still have players with money
        while self.can_play?
          self.place_bets
        end
      end
    end

    # we started play
    if @deck:
      self.settle_round if started_round
      @io.show_stats(@players, @num_rounds, @game_num)
    end

  end

  # can we attempt to play one more round on the current deck
  def can_play?
    return @deck.cards.length > 0 && players.length > 0
  end

  # does the user want to continue playing with a new deck?
  def continue_play?
    return @io.prompt_yes_no("Would you like to continue playing? [no]\n 
                             This will be game #{@num_decks}", "no")
  end

  # initializes the game
  def start_game
    @dealer = Player.new("Dealer", 0)
    @deck = Decks.new(@io.prompt_positive("Number of decks at table? [#{Decks::MIN_DECKS}]", Decks::MIN_DECKS))
    
    # in case user wants to change the default amount of cash per player
    @cash = @io.prompt_positive("How much cash per player? [#{@cash}]", @cash)

    # create the players!
    1.upto(@io.prompt_positive("Number of players? [1]",1)) do |i|
      @players << Player.new(@io.prompt("Player Name? [Player #{i}]","Player #{i}"), @cash)
    end
  end

  # asks each player still in the game bet
  def place_bets
    @players.each
  end
end
