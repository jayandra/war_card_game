require 'minitest/autorun'
require 'pry'

# Add the lib directory to the load path
$LOAD_PATH.unshift File.expand_path('../', __FILE__)

# Require all the source files
require_relative '../lib/cards'
require_relative '../lib/player'
require_relative '../lib/war_card_game'
