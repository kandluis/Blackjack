# Game Class
#
# => Implements a blackjack game
# => Properties
#   => .io = io device class used to display messages to the player
#   => .dealer = Player Class fulfilling dealer role
#   => .deck = Decks class fulfilling the role of the table shoe
#   => .deck_num = number of decks in a shoe as specified by the player
#   => .num_rounds = tracks blackjack rounds played
#   => .game_num = tracks number of full games played
#   => .cash = cash each player starts with in a new game
#   => .players = Player Set containing playable contestants
#   => .losers = Player Set containing unplayable contestants
#   => .min_bet = minimum allowed bet on a single hand
#   => .max_bet = maximum allowed bet on a single hand
#   => .bet_step = allowed bet increments
#   => .dealer_stay = dealer will hit until reaching this value
#   => .wait = wait time in seconds between each round of the game

require 'InputOutput'
require 'Cards'
require 'Players'

trap("SIGINT") { throw :quit }

class Game

  # Set debug to True to see dealer hands and game deck
  attr_accessor :debug

  # Game options (default starting cash for each player)
  attr_accessor :cash

  def initialize()
    @io = InputOutput.new
    @dealer, @deck = nil
    @num_rounds, @deck_num = 0
    @game_num = 1
    @cash = 1000
    @players = []
    @losers = []

    # using http://www.pagat.com/banking/blackjack.html as reference for the rules
    # of the blackjack game 
    # TODO: add user ability to modify these parameters
    @min_bet = 5
    @max_bet = 100
    @bet_step = 1
    @dealer_stay = 17 

    @wait = 1
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
    catch :quit do
      @io.welcome_msg
      self.init_game

      # if user quits, go ahead and still show end results
      # user want to continue
      while @game_num == 1 || self.continue_play?
        self.start_game
        # play while we have cards and we still have players with money
        while self.can_play?
          @io.start_round(@game_num, @num_rounds + 1)
          @io.show_deck(@deck) if @debug

          self.reset_round
          self.place_bets

          # we consider a round to have started once the bets are placed

          started_round = true

          # deal out cards (including dealer)
          if (!self.initial_deal)
            self.incomplete_round
            break
          end

          self.show_hands if @debug

          if !@dealer.main_hand.bj? 
            # ran out of cards during the round?
            if !self.play_round
              self.incomplete_round
              break
            end
          end

          self.finish_round
          started_round = false
        end

        @game_num += 1
      end
    end

    # we started play
    if @deck:
      self.incomplete_round if started_round
      @io.show_stats(@players, @num_rounds, @game_num)
    end

  end

  # can we attempt to play one more round on the current deck
  def can_play?
    return @deck.cards.length > 0 && @players.length > 0
  end

  # does the user want to continue playing with a new deck?
  def continue_play?
    return @io.continue_play?(@game_num)
  end

  # initializes the game
  def init_game
    @dealer = Player.new("Dealer", 0)
    @deck_num = @io.get_shoe_size

    # in case user wants to change the default amount of cash per player
    @cash = @io.get_default_cash(@cash)

    # create the players!
    1.upto(@io.get_num_players) do |i|
      @players << Player.new(@io.get_player_name(i), @cash)
    end
  end

  # starts blackjack game with a new deck of cards
  def start_game
    @deck = Decks.new(@deck_num)
    @deck.shuffle
  end

  # asks each player still in the game to bet
  def place_bets
    for player in @players
      # allow players with little cash to bet
      min = (@min_bet < player.cash) ? @min_bet : player.cash
      max = (@max_bet < player.cash) ? @max_bet : player.cash
      player.bet = @io.get_bet(player, min, max, @bet_step)
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
        if card == nil
          return false
        end
        player.hands[0].hit(card)
      end
    end

    return true
  end

  # displays the hand of the dealer and players (used for debugging)
  def show_hands
    @io.show_hands(@players + [@dealer])
  end

  # plays a single round of black jack! Each player has 2 cards, dealer also has 2
  # Needs to show dealer card to players, and then ask for action and loop until
  # everyone is bust or everyone is stand!
  # Returns false if the round could not be completed, true otherwise
  def play_round
    @io.show_card(@dealer, 0, 0)
    # players play!
    for player in @players
      for hand in player.hands
        @io.show_hand(player,hand)
        while hand.hit?
          # on black jack, let the user know he's staying
          if hand.bj?
            @io.player_bj
            hand.stand
            break
          end
          card = @deck.deal(1)
          if card == nil
            return false
          end
          card = card[0]
          if card == nil
            return false
          end
          result = nil
          # analyze results to figure out what needs to get done!
          while not result
            result = @io.get_move
            if result == "m"
              result = nil
              @io.show_stats(@players, @num_rounds, @game_num)
            elsif result == "h"
              hand.hit(card) 
            elsif result == "d" 
              hand.hit(card)
              player.double_bet(hand)
              hand.stand
            elsif result == "s"
              hand.stand
              @deck.add_card(card)
            elsif result == "p" 
              if !player.split_hand(hand)
                @io.retry
                @deck.add_card(card)
                result = nil
              else 
                # double aces means we stand
                split = player.hands[player.hands.length - 1]
                if split.has_aces? && hand.has_aces?
                  # get one more card per hand and then stand
                  cards = @deck.deal(2)
                  if cards == nil
                    return false
                  end
                  hands = [hand,split]
                  cards.each_with_index{ |i, c| 
                    hands[i].hit(c)
                  }
                end
              end
            else
              @io.retry
              result = nil
            end

            # update hand
            @io.show_hand(player, hand)
          end
        end
      end
    end

    # if we made it to this point, we finished the round with cards left on the deck
    return true
  end

  # after each round, we want to empty out the player hands and reset their bets
  def reset_round
    for player in @players + [@dealer]
      player.start_new_round
      player.bet = 0
    end
  end

  # Figure out to whom the winnings need to be distribute
  def finish_round
    # increment rounds
    @num_rounds += 1
    # now we need to clean up by settling all the bets
    dealer_hand = @dealer.hands[0]

    # have the dealer play his hand
    @io.finish_round
    @io.show_hand(@dealer, dealer_hand)
    while !dealer_hand.bust? && dealer_hand.max_hand < 17
      card = @deck.deal(1)
      if card == nil
        return false
      end
      card = card[0]
      if card == nil
        return false
      end
      dealer_hand.hit(card)
      @io.show_hand(@dealer, dealer_hand)
      sleep(@wait)

    end

    # now check results
    for player in @players
      for hand in player.hands
        @io.show_hand(player, hand)
        # if both bust or both bj or values are equal
        if (hand.bust? && dealer_hand.bust?) ||
          (hand.bj? && dealer_hand.bj?) || 
          (hand.max_hand == dealer_hand.max_hand)
          @io.player_tie(player)
        else
          # player busted or dealer black jack or both player and dealer busted
          # or player lost
          if (hand.bust? || dealer_hand.bj? ||
            (!dealer_hand.bust? && hand.max_hand < dealer_hand.max_hand))
            @dealer.won_bet(hand.bet)
            @io.player_lose(player)
          # player black jack
          elsif hand.bj?
            player.won_bet(2.5*hand.bet)
            @io.player_win_bj(player)
          # dealer busted or player wins
          elsif dealer_hand.bust? || hand.max_hand > dealer_hand.max_hand
            player.won_bet(2*hand.bet)
            @io.player_win(player)
          else 
            raise Exception("Should not get here! Error when checking results")
          end
        end
      end
    end

    # find broke players
    @losers += @players.select{ |player| player.cash <= 0 }
    @players = @players.select{ |player| player.cash > 0}

  end

  # this is executed in the case of an incomplete round
  def incomplete_round
    @io.out_of_cards
    # restore player bets 
    for player in @players
      player.cash += player.bet
    end

    # reset players
    self.reset_round
  end
end
