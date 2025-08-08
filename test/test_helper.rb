require 'minitest/autorun'
require 'pry'

# Add the lib directory to the load path
$LOAD_PATH.unshift File.expand_path('../', __FILE__)

# Require all the source files
require_relative '../cards'
require_relative '../player'
require_relative '../war_card_game'
