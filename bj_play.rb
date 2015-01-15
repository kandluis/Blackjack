#!/usr/bin/ruby

require 'getoptlong'
require 'bj_game'

# Prints out help for BlackJack (BlackHack!) 
def usage
  puts
  puts "ruby bj_play.rb [OPTIONS]"
  puts
  puts " -c, --cash [integer]:"
  puts " set the player's starting cash"
  puts
  puts " -d, --debug:"
  puts " debug mode; shows deck and dealer hands"
  puts
  puts " -h, --help:"
  puts " show help"
  puts
end

opts = GetoptLong.new(
  [ "--cash", "-c", GetoptLong::REQUIRED_ARGUMENT],
  [ "--debug", "-d", GetoptLong::NO_ARGUMENT ],
  [ "--help", "-h", GetoptLong::NO_ARGUMENT ]
)

# create the game and parse inputs!
game = Game.new
opts.each do |opt, arg|
  case opt
    when "--cash"
      if arg.to_i <= 0
        puts "Incorrect amount of cash to begin game. Defaulting to $#{game.cash}."
      else
        game.cash = arg
      end 
    when "--debug"
      game.debug = true
    when "--help"
      usage
      exit
    end
end

game.play
