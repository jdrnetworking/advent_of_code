#!/usr/bin/env ruby

def parse(input)
  input.split(/\n/).map { |line| line.scan(/[ns]?[ew]/).to_a }
end

def identify(directions)
  directions.reduce([0, 0]) { |(x, y), direction|
    case direction
    when 'e'
      x += 2
    when 'w'
      x -= 2
    when 'ne'
      x += 1
      y += 1
    when 'nw'
      x -= 1
      y += 1
    when 'se'
      x += 1
      y -= 1
    when 'sw'
      x -= 1
      y -= 1
    end
    [x, y]
  }
end

def flip(tiles, lines)
  lines.reduce(tiles) { |tiles, directions|
    tiles.tap { |t| t[identify(directions)] += 1 }
  }
end

def flip?(current, black_neighbors)
  (current.odd? && (black_neighbors.zero? || black_neighbors > 2)) ||
    (current.even? && black_neighbors == 2)
end

def valid_coordinates?(x, y)
  (x + y).even?
end

def count_black_neighbors(tiles, x, y)
  [[-2, 0], [-1, 1], [1, 1], [2, 0], [1, -1], [-1, -1]].count { |offset_x, offset_y|
    tiles[[x + offset_x, y + offset_y]].odd?
  }
end

def age(tiles)
  min_x, max_x = tiles.keys.map(&:first).minmax
  min_y, max_y = tiles.keys.map(&:last).minmax
  new_tiles = tiles.dup
  ((min_x - 2)..(max_x + 2)).to_a.product(((min_y - 2)..(max_y + 2)).to_a)
    .select { |coords| valid_coordinates?(*coords) }
    .each do |x, y|
      new_tiles[[x, y]] += 1 if flip?(tiles[[x, y]], count_black_neighbors(tiles, x, y))
    end
  new_tiles
end

if $0 == __FILE__
  lines = parse(ARGF.read)
  tiles = Hash.new { |h,k| h[k] = 0 }
  flip(tiles, lines)
  puts tiles.values.count { |v| v.odd? }

  100.times do
    tiles = age(tiles)
  end
  puts tiles.values.count { |v| v.odd? }
end
