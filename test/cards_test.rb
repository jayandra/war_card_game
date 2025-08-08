require_relative 'test_helper'

class CardsTest < Minitest::Test
  def setup
    @deck = Cards.new
  end

  def test_initialization_creates_52_cards
    assert_equal 52, @deck.cards.size
  end

  def test_shuffle_changes_card_order
    original_order = @deck.cards.dup
    @deck.shuffle
    refute_equal original_order, @deck.cards
    assert_equal original_order.size, @deck.cards.size
  end

  def test_distribute_creates_correct_number_of_piles
    piles = @deck.distribute(4).to_a
    assert_equal 4, piles.size
    assert_equal 13, piles.first.size
    assert_equal 13, piles.last.size
  end

  def test_distribute_with_uneven_distribution
    piles = @deck.distribute(5).to_a
    assert_equal 6, piles.size
    assert_equal 10, piles[0].size
    assert_equal 10, piles[1].size
    assert_equal 10, piles[2].size
    assert_equal 10, piles[3].size
    assert_equal 10, piles[4].size
    assert_equal 2, piles.last.size
  end
end
