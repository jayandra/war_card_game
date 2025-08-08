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

  def test_collect_war_cards_for_player
    # Setup test cards
    cards = [
      Cards::Card.new(val: 'A', rank: 14, suit: :hearts),
      Cards::Card.new(val: 'K', rank: 13, suit: :spades),
      Cards::Card.new(val: 'Q', rank: 12, suit: :diamonds),
      Cards::Card.new(val: 'J', rank: 11, suit: :clubs)
    ]
    
    # Test collecting from a player with more than 3 cards
    player = Player.new("Test Player")
    player.add_deck(cards.dup)
    collected = @game.send(:collect_war_cards_for_player, player)
    assert_equal 3, collected.size
    assert_equal 1, player.deck.size  # 4 total - 3 collected = 1 remaining
    assert_equal 0, player.wone_cards.size  # No won cards yet
    
    # Test collecting from a player with exactly 3 cards
    player = Player.new("Test Player 2")
    player.add_deck(cards[0..2])
    collected = @game.send(:collect_war_cards_for_player, player)
    assert_equal 3, collected.size
    assert_equal 0, player.deck.size
    
    # Test collecting from a player with less than 3 cards
    player = Player.new("Test Player 3")
    player.add_deck(cards[0..1])
    collected = @game.send(:collect_war_cards_for_player, player)
    assert_equal 2, collected.size
    assert_equal 0, player.deck.size
    
    # Test collecting from a player with no cards
    player = Player.new("Test Player 4")
    collected = @game.send(:collect_war_cards_for_player, player)
    assert_empty collected
  end

  def test_players_with_3_cards_each_with_first_2_being_same
    # Setup test cards - first two cards are the same rank for both users
    card1 = Cards::Card.new(val: 'K', rank: 13, suit: :hearts)    # Player 1 first card
    card2 = Cards::Card.new(val: 'K', rank: 13, suit: :diamonds)  # Player 2 first card (same rank)
    card3 = Cards::Card.new(val: 'Q', rank: 12, suit: :clubs)     # Player 1 second card
    card4 = Cards::Card.new(val: 'Q', rank: 12, suit: :spades)    # Player 2 second card (same rank)
    card5 = Cards::Card.new(val: '10', rank: 10, suit: :hearts)   # Player 1 third card
    card6 = Cards::Card.new(val: '9', rank: 9, suit: :diamonds)   # Player 2 third card
    
    @player1.add_deck([card1, card3, card5])
    @player2.add_deck([card2, card4, card6])

    
    # Play the round
    @game.send(:play_round, [@player1, @player2])
    
    # After the tie is resolved, player1 should win all cards
    # because their second card (Q) is higher than player2's second card (J)
    assert_equal 0, @player1.deck.size, "Player 1 should have no cards left in deck"
    assert_equal 0, @player2.deck.size, "Player 2 should have no cards left in deck"
    assert_equal 6, @player1.wone_cards.size, "Player 1 should have all 6 cards"
    assert_equal 0, @player2.wone_cards.size, "Player 2 should have no won cards"
  end

  def test_players_with_5_cards_each_with_first_4_being_same    
    # Setup test cards - first four cards are the same rank for both users
    p1_card1 = Cards::Card.new(val: 'K', rank: 13, suit: :hearts)    # First card (tie)
    p1_card2 = Cards::Card.new(val: 'K', rank: 13, suit: :diamonds)  # Second card (tie)
    p1_card3 = Cards::Card.new(val: 'Q', rank: 12, suit: :clubs)     # Third card (tie)
    p1_card4 = Cards::Card.new(val: 'Q', rank: 12, suit: :spades)    # Fourth card (tie)
    p1_card5 = Cards::Card.new(val: 'J', rank: 11, suit: :hearts)    # Fifth card (wins against J)
    
    # Player 2's cards
    p2_card1 = Cards::Card.new(val: 'K', rank: 13, suit: :hearts)    # First card (tie)
    p2_card2 = Cards::Card.new(val: 'K', rank: 13, suit: :diamonds)  # Second card (tie)
    p2_card3 = Cards::Card.new(val: 'Q', rank: 12, suit: :clubs)     # Third card (tie)
    p2_card4 = Cards::Card.new(val: 'Q', rank: 12, suit: :spades)    # Fourth card (tie)
    p2_card5 = Cards::Card.new(val: '5', rank: 5, suit: :hearts)    # Fifth card (loses to Q)
    
    @player1.add_deck([p1_card1, p1_card2, p1_card3, p1_card4, p1_card5])
    @player2.add_deck([p2_card1, p2_card2, p2_card3, p2_card4, p2_card5])
    
    # Play the round
    @game.send(:play_round, [@player1, @player2])
    
    # After the multi-level tie is resolved, player1 should win all cards
    # because their fifth card (Q) is higher than player2's fifth card (J)
    assert_equal 0, @player1.deck.size, "Player 1 should have no cards left in deck"
    assert_equal 0, @player2.deck.size, "Player 2 should have no cards left in deck"
    assert_equal 10, @player1.wone_cards.size, "Player 1 should have all 10 cards"
    assert_equal 0, @player2.wone_cards.size, "Player 2 should have no won cards"
  end

  def test_only_2_or_4_players_are_allowed
    # Test with invalid input first (3 players)
    input = StringIO.new("3\n2\nPlayer 1\nPlayer 2\n")  # First invalid (3), then valid (2)
    output = StringIO.new
    game = WarCardGame.new(input: input, output: output)
    
    # The output should contain the error message for invalid player count
    output.rewind
    output_str = output.read
    assert_includes output_str, "Error: Only 2 or 4 players are allowed.", 
                   "Should show error message for invalid player count"
    assert_includes output_str, "Starting game with 2 players.",
                   "Should then accept 2 players after invalid input"
    
    # Test with valid input (2 players)
    input = StringIO.new("2\nPlayer 1\nPlayer 2\n")
    output = StringIO.new
    game = WarCardGame.new(input: input, output: output)
    
    output.rewind
    output_str = output.read
    assert_includes output_str, "Starting game with 2 players.", 
                   "Should accept 2 players"
    
    # Test with another valid input (4 players)
    input = StringIO.new("4\nPlayer 1\nPlayer 2\nPlayer 3\nPlayer 4\n")
    output = StringIO.new
    game = WarCardGame.new(input: input, output: output)
    
    output.rewind
    output_str = output.read
    assert_includes output_str, "Starting game with 4 players.", 
                   "Should accept 4 players"
  end
end
