# Card Wars Game

A Ruby implementation of War card game as described in `problem.txt`.

## Installation

1. Clone this repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   bundle install
   ```

## Running the Game

```bash
ruby play_game.rb
```

## Testing

The project uses Minitest for testing. To run the test suite:

```bash
# Run all tests
bundle exec rake test

# Run a specific test file
TEST=test/cards_test.rb bundle exec rake test
```

## Project Structure

- `war_card_game.rb` - Core game logic
- `play_game.rb` - Main script to start the game
- `cards.rb` - Card and deck implementation
- `player.rb` - Player implementation