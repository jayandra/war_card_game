class Player
  attr_accessor :name, :deck, :wone_cards

  def initialize(name)
    @name = name
    @deck = []
    @wone_cards = []
  end

  def add_deck(deck)
    @deck = deck
  end

  def add_cards_won(cards)
    p "#{@name} added #{cards.map(&:val)} cards to their deck"
    @wone_cards.insert(-1, *cards)
  end

  def play_top_card
    top_card = @deck.shift || @wone_cards.shift
    p "#{@name} played #{top_card.val} of #{top_card.suit}"
    top_card
  end

  def has_cards?
    !@deck.empty? || !@wone_cards.empty?
  end
end
