#!/usr/bin/env ruby

def parse_decks(input)
  players_input = input.split(/\n\n/)
  players_input.map { |player_input|
    player_input.split(/\n/)[1..-1].map(&:to_i)
  }
end

def play(decks, recursive: false)
  prior_hands = []
  until decks.any?(&:empty?) do
    prior_hands.push(decks.map(&:dup))
    winning_player, cards = play_round(decks, recursive: recursive, prior_hands: prior_hands)
    decks[winning_player].concat(cards)
  end
  [decks.find_index { |deck| !deck.empty? }, decks]
end

def play_round(decks, recursive: false, prior_hands: [])
  if recursive && prior_hands[0..-2].any? { |prior_hand| prior_hand == decks }
    puts "Player 1 wins by prior hand"
    return [0, []]
  end
  cards = decks.map(&:shift)
  if recursive && cards.map.with_index.all? { |card, player| decks[player].size >= card }
    puts "Recursing"
    winning_player = play(decks.map.with_index { |deck, player| deck.take(cards[player]) }).first
    loot = winning_player == 0 ? cards : cards.reverse
  else
    sorted = cards.map.with_index.sort_by(&:first).reverse
    winning_player = sorted.first.last
    loot = sorted.map(&:first)
  end
  [winning_player, loot]
end

def score(deck)
  deck.reverse.map.with_index(1) { |value, index| value * index }.sum
end

if $0 == __FILE__
  original_decks = parse_decks(ARGF.read)
  winning_player, decks = play(original_decks.map(&:dup))
  puts score(decks[winning_player])

  winning_player, decks = play(original_decks.map(&:dup), recursive: true)
  puts score(decks[winning_player])
end
