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

class Player
	attr_reader :name, :deck, :wone_cards

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

class WarCardGame
	def initialize
		@players = []
		@cards = Cards.new
		@cards.shuffle

		puts "How many players will be playing the game?"
		n = gets.chomp.to_i
		card_distributions = @cards.distribute(n).to_a

		1.upto(n) do |i|
		  puts "Enter name of Player #{i}:"
		  p = gets.chomp
		  player = Player.new(p)
		  player.add_deck(card_distributions[i-1] || [])
		  @players << player
		end
	end

	def play
		round = 1
  	puts "\n--- Starting Game ---"

  	loop do
			puts "\n--- Round #{round} ---"
			# Play the round
			continue_game = play_round
			round += 1
			
			# Check if the game is over
			unless continue_game
				puts "\nGame Over!"
				break
			end
			
			# Small delay to make the game playable
			sleep(0.5)
  	end
	end

	private

	def active_players
		@players.select{|p| p.has_cards?}
	end

	def play_round(players = active_players)
		face_up_cards = {}

		# Play one card from each player
		players.each do |p|
		  if p.has_cards?
		    face_up_cards[p] = p.play_top_card
		  end
		end

		return if face_up_cards.empty?  # No cards were played

		winning_rank = face_up_cards.values.map(&:rank).max
		winners = face_up_cards.select { |_, c| c.rank == winning_rank }.to_h

		if winners.size == 1
		  winner = winners.keys.first
		  puts "#{winner.name} wins this round with a #{winners[winner].val} of #{winners[winner].suit}!"
		  winner.add_cards_won(face_up_cards.values)
			print_players_cards_at_hand
		else
		  play_tie(winners.keys, winners, winning_rank, face_up_cards.values - winners.values)
			print_players_cards_at_hand
		end

		# Check for game over
		remaining_players = @players.select { |p| p.has_cards? }
		if remaining_players.size == 1
		  puts "\n #{remaining_players.first.name} wins the game!!!"
		  return false  # Game over
		end

		true  # Continue playing
	end

	def print_players_cards_at_hand
		@players.each do |p|
			puts "#{p.name}: deck:#{p.deck.map(&:val)}  wone:#{p.wone_cards.map(&:val)}"
		end
	end

	def play_tie(tied_players, face_up_cards, winning_rank, cards_played = [])
		p "Tie between #{tied_players.map(&:name).join(' and ')}! Starting a Tie Breaker..."
		war_cards = {}

		# Collect face down cards from each player in the war
		# If a user doesn't have any cards in deck for face-down use their current face-up card for this tie round until eliminated.
		tied_players.each do |player|
			cards_played_this_round = []
			
			# Play up to 3 cards (or all remaining if less than 3)
			[3, (player.deck.size + player.wone_cards.size)].min.times do
				break unless player.has_cards?
				card = player.play_top_card
				cards_played_this_round << card if card
			end
			
			war_cards[player] = cards_played_this_round
			cards_played += cards_played_this_round

			# Keep tied players's current face-up card as their card if they don't have any new to set aside
			if cards_played_this_round.empty? && face_up_cards[player].rank >= winning_rank
				war_cards[player] = face_up_cards[player]
			end
		end

		active_players = tied_players.select { |p| !war_cards[p].empty? }
  
		# If only one player has cards left, they win
		if active_players.size == 1
			winner = active_players.first
			winner.add_cards_won(face_up_cards.values.flatten + cards_played)
			p "#{winner.name} breaks the tie!!"
			return
		end

		# Try up to 3 times to find a winner from war cards
		3.times do |attempt|
		  # Play one card from each player's war cards
		  face_up_war_cards = {}
		  active_players.each do |player|
		    next if war_cards[player].empty?  # Skip if no more war cards
		    face_up_war_cards[player] = war_cards[player].shift
		  end

		  # If no cards were played, break the loop
		  break if face_up_war_cards.empty?

		  # Find the highest rank among the played cards
		  max_rank = face_up_war_cards.values.map(&:rank).max
		  winners = face_up_war_cards.select { |_, card| card.rank == max_rank }.keys

		  if winners.size == 1
		    # We have a winner!
		    winner = winners.first
		    p "#{winner.name} wins the tie with a #{face_up_war_cards[winner].val} of #{face_up_war_cards[winner].suit}!"

				all_cards = face_up_cards.values.flatten + cards_played
		    winner.add_cards_won(all_cards)
		    return
		  end

		  # If this was the last attempt, prepare for recursive call
		  if attempt == 2
		    # Call play_tie until we have a winner
			  play_tie(winners, face_up_war_cards, max_rank, cards_played)
		    return
		  end
		end
	end
end
