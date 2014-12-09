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
    @bet_step = 1
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
      # user want to continue
      while @game_num == 1 || self.continue_play?
        # play while we have cards and we still have players with money
        while self.can_play?
          @io.start_round(@game_num, @num_rounds + 1)
          @io.show_deck(@deck) if @debug

          self.place_bets
          started_round = true

          if (!self.initial_deal) # takes care of dealing with dealer, too
            @io.display("---Dealer ran out of cards this round!---\n\n")
            break
          end
          self.show_hands if @debug

          if !@dealer.hands[0].bj? 
            self.play_round
          end

          self.finish_round
        end
        @game_num += 1
      end
    end

    # we started play
    if @deck:
      self.finish_round if started_round
      @io.show_stats(@players, @num_rounds, @game_num)
    end

  end

  # can we attempt to play one more round on the current deck
  def can_play?
    return @deck.cards.length > 0 && @players.length > 0
  end

  # does the user want to continue playing with a new deck?
  def continue_play?
    return @io.prompt_yes_no("Would you like to continue playing? [no]\n This will be game #{@game_num}", "no")
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

    # shuffle the deck
    @deck.shuffle
  end

  # asks each player still in the game to bet
  def place_bets
    for player in @players
      player.bet = @io.prompt_bet(player, @min_bet, @max_bet, @bet_step)
      hand = Hand.new
      player.add_hand(hand)
      player.place_bet(hand)
    end

    # dealer starts his hand
    @dealer.add_hand(Hand.new)
  end

  # deals the initial set of cards. Since random shuffle, no to simulate - just
  # give everyone two cards.
  def initial_deal
    for player in @players + [@dealer]
      pcards = @deck.deal(2)
      if pcards == nil
        return false
      end
      for card in pcards
        player.hands[0].hit(card)
      end
    end

    return true
  end

  # displays the hand of the dealer and players (used for debugging)
  def show_hands
    players = @players + [@delaer]
    for player in @players + [@dealer]
      @io.display(player.to_s)
      for hand in player.hands
        @io.display("     \##{hand.to_s}")  
      end
    end
  end

  # plays a single round of black jack! Each player has 2 cards, dealer also has 2
  # Needs to show dealer card to players, and then ask for action and loop until
  # everyone is bust or everyone is stand!
  # Returns false if the round could not be completed, true otherwise
  def play_round
    # display the dealer face up card
    @io.display("Dealer has: #{@dealer.hands[0].cards[0]}\n\n")
    # players play!
    for player in @players
      for hand in player.hands
        while hand.hit?
          @io.display("#{player.name}. Current hand is: #{hand.to_s}.")
          card = deck.deal(1)
          if card == nil
            return false
          end
          result = nil
          # analyze results to figure out what needs to get done!
          while not result
            result = @io.get_move
            if result == "h"
              hand.hit(card) 
            elsif result == "d" 
              hand.hit(card)
              player.double_bet(hand)
              hand.stand
            elsif result == "s"
              hand.stand
              deck.add_card(card)
            elsif result == "p" 
              if !player.split_hand(hand)
                @io.try_again
                deck.add_card(card)
                result = nil
              else
                @io.show_hands(player) if @debug
                split = hand.split
                hand.hit(card)
                newcard = deck.dealer(1)
                if newcard == nil
                  return false
                end
                split.hit(newcard)

                # double aces means we stand
                if split.has_aces? && hand.has_aces?
                  hand.stand
                  split.stand
                end
              end
            else
              @io.try_again
              result = nil
            end
          
            # Invalid result
            @io.try_again
            deck.add_card(card)
          end
        end
      end
    end
  end
end
