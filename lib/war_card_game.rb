require_relative 'cards'
require_relative 'player'

class WarCardGame
  def initialize(input: $stdin, output: $stdout)
    @input = input
    @output = output
    @players = []
    @cards = Cards.new
    @cards.shuffle

    setup_players
  end

  def setup_players
    loop do
      @output.puts "How many players will be playing the game? (2 or 4 players only)"
      n = @input.gets.chomp.to_i
      
      if [2, 4].include?(n)
        @output.puts "Starting game with #{n} players."
        card_distributions = @cards.distribute(n).to_a
        
        1.upto(n) do |i|
          @output.puts "Enter name of Player #{i}:"
          name = @input.gets.chomp
          player = Player.new(name)
          player.add_deck(card_distributions[i-1] || [])
          @players << player
        end
        break
      else
        @output.puts "Error: Only 2 or 4 players are allowed. Please try again. \n\n"
      end
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
			# sleep(0.5)
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
			card = p.play_top_card
			p "#{p.name} played #{card.val} of #{card.suit}"
		  face_up_cards[p] = card
		end

		winning_rank = face_up_cards.values.map(&:rank).max
		winners = face_up_cards.select { |_, c| c.rank == winning_rank }.to_h

		if winners.one?
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
		if remaining_players.one?
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
		p "Tie between #{tied_players.map(&:name).join(' , ')}! Starting a Tie Breaker..."
		war_cards = {}
		previous_face_up_cards = {}

		# Collect face down cards from each player in the war
		# If a user doesn't have any cards in deck for face-down use their current face-up card for this tie round until eliminated.
		tied_players.each do |player|
		  cards = collect_war_cards_for_player(player)
		  cards_played += cards
			war_cards[player] = cards.any? ? cards : [face_up_cards[player]]
		end

		# Try up to 3 times to find a winner from war cards
		3.times do |attempt|
		  # Play one card from each player's war cards
		  current_face_up_cards = {}
		  
			# If a user runs out of card mid tie-breaker; use their last open-card for this round until eliminated
		  tied_players.each do |player|
		  	if war_cards[player].empty?
		  	  current_face_up_cards[player] = previous_face_up_cards[player]
		  	else
		  	  current_face_up_cards[player] = war_cards[player].shift
		  	end
		  end
			previous_face_up_cards = current_face_up_cards

		  # If no cards were played, break the loop
		  break if current_face_up_cards.empty?

		  max_rank = current_face_up_cards.values.map(&:rank).max
		  winners = current_face_up_cards.select { |_, card| card.rank == max_rank }.keys

		  if winners.one?
		    winner = winners.first
		    card = current_face_up_cards[winner]
		    p "#{winner.name} wins the tie with a #{card.val} of #{card.suit}!"
		    
		    # Add all cards from the original round (i.e. face_up_cards) and all cards played during the tiebreaker
		    all_cards = face_up_cards.values + cards_played
		    winner.add_cards_won(all_cards)
		    return
		  end

		  # If this was the last attempt, prepare for recursive call
		  if attempt == 2
		    # Call play_tie with the current face up cards and all cards played so far
		    play_tie(winners, current_face_up_cards, max_rank, cards_played)
		    return
		  end
		end
	end

	def collect_war_cards_for_player(player, max_cards = 3)
		cards_played = []
		cards_available = [player.deck.size + player.wone_cards.size, max_cards].min
		
		cards_available.times do
			break unless player.has_cards?
			card = player.play_top_card
			if card
				p "#{player.name} added #{card.val} of #{card.suit}"
				cards_played << card 
			end
		end
		
		cards_played
	end
end
