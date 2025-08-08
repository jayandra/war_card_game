require_relative 'test_helper'

class PlayerTest < Minitest::Test
  def setup
    @player = Player.new("Test Player")
    @cards = [
      Cards::Card.new(val: 2, rank: 2, suit: :hearts),
      Cards::Card.new(val: 'A', rank: 14, suit: :spades)
    ]
  end

  def test_initialization
    assert_equal "Test Player", @player.name
    assert_empty @player.deck
    assert_empty @player.wone_cards
  end

  def test_add_deck
    @player.add_deck(@cards)
    assert_equal @cards, @player.deck
  end

  def test_add_cards_won
    @player.add_cards_won(@cards)
    assert_equal @cards, @player.wone_cards
  end

  def test_play_top_card
    @player.add_deck(@cards.dup)
    card = @player.play_top_card
    assert_equal 2, card.val
    assert_equal :hearts, card.suit
    assert_equal 1, @player.deck.size
  end

  def test_play_top_card_from_won_cards_when_deck_empty
    @player.add_cards_won(@cards.dup)
    card = @player.play_top_card
    assert_equal 2, card.val
    assert_equal 1, @player.wone_cards.size
  end

  def test_has_cards
    refute @player.has_cards?
    @player.add_deck([@cards.first])
    assert @player.has_cards?
    @player.deck = []
    refute @player.has_cards?
    @player.add_cards_won([@cards.last])
    assert @player.has_cards?
  end
end
