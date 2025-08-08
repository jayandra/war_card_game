class Cards
  Card = Struct.new(:val, :rank, :suit)

  attr_accessor :cards
  def initialize
    @cards = []
    
    %i(heart diamonds clubs spades).each do |s|
      [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A'].each_with_index do |v, i|
        @cards << Card.new(val: v, rank: i + 2, suit: s)
      end
    end
  end

  def shuffle
    @cards.shuffle!
  end

  def distribute(number_of_players)
    @cards.each_slice(52 / number_of_players)
  end
end
