require_relative 'test_helper'

class WarCardGameTest < Minitest::Test
  def setup
    # Set up test players
    @player1 = Player.new("Player 1")
    @player2 = Player.new("Player 2")
    
    # Set up test cards
    @card1 = Cards::Card.new(val: 'K', rank: 13, suit: :hearts)
    @card2 = Cards::Card.new(val: 'Q', rank: 12, suit: :spades)
    @test_deck = [@card1, @card2]
    
    # Create a test cards instance and stub the distribute method
    @cards = Cards.new
    def @cards.distribute(n)
      [@test_deck.dup, @test_deck.dup]
    end
    
    # Create a test input/output double
    @input = StringIO.new("2\nPlayer 1\nPlayer 2\n")
    @output = StringIO.new
    
    # Create the game with our test dependencies
    @game = WarCardGame.new(input: @input, output: @output)
    @game.instance_variable_set(:@players, [@player1, @player2])
    @game.instance_variable_set(:@cards, @cards)
  end

  def test_initialization
    input = StringIO.new("2\nPlayer 1\nPlayer 2\n")
    output = StringIO.new
    game = WarCardGame.new(input: input, output: output)
    assert_instance_of WarCardGame, game
    assert_instance_of Cards, game.instance_variable_get(:@cards)
  end

  def test_active_players
    @player1.add_deck([@card1])
    active = @game.send(:active_players)
    assert_equal [@player1], active
    
    @player2.add_deck([@card2])
    active = @game.send(:active_players)
    assert_equal [@player1, @player2], active
  end

  def test_play_round_with_clear_winner
    # Set up players with known cards
    @player1.add_deck([@card1])  # K of hearts (rank 13)
    @player2.add_deck([@card2])  # Q of spades (rank 12)
    
    # Player 1 should win this round
    @game.send(:play_round, [@player1, @player2])
    
    assert_equal 0, @player1.deck.size  # Played their card
    assert_equal 0, @player2.deck.size  # Played their card
    assert_equal 2, @player1.wone_cards.size  # Should have both cards now
    assert_equal 0, @player2.wone_cards.size
  end

  def test_play_round_with_tie
    # Both players have the same rank card
    tie_card = Cards::Card.new(val: 'K', rank: 13, suit: :diamonds)
    @player1.add_deck([@card1])  # K of hearts
    @player2.add_deck([tie_card])  # K of diamonds
    
    # Stub the play_tie method to avoid complex tie logic in this test
    def @game.play_tie(*args)
      @tie_was_called = true
    end
    
    @game.send(:play_round, [@player1, @player2])
    
    assert @game.instance_variable_get(:@tie_was_called), "play_tie should be called on a tie"
  end
end
