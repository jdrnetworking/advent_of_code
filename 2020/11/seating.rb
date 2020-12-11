#!/usr/bin/env ruby

def parse_seats(input)
  input.split(/\r?\n/).map { |row|
    row.chars.map { |char| char == 'L' }
  }
end

def empty(grid)
  grid.map { |row| row.map { false } }
end

def life(seating_chart:, current:, stable_range: 1..3)
  seating_chart.map.with_index { |row, row_num|
    row.map.with_index { |eligible, col_num|
      next false unless eligible
      if count_adjacent(current, row_num, col_num) < stable_range.min
        true
      elsif count_adjacent(current, row_num, col_num) > stable_range.max
        false
      else
        current[row_num][col_num]
      end
    }
  }
end

def count_adjacent(grid, row, col)
  adjacent_coords(grid, row, col).count { |r, c| grid[r][c] }
end

def adjacent_coords(grid, row, col)
  ((row - 1)..(row + 1)).flat_map { |r|
    ((col - 1)..(col + 1)).map { |c|
      next if r == row && c == col
      next unless in_grid?(grid, r, c)
      [r, c]
    }
  }.compact
end

def in_grid?(grid, row, col)
  (0...grid.size).cover?(row) && (0...grid[0].size).cover?(col)
end

def life2(seating_chart:, current:, stable_range: 1..4)
  seating_chart.map.with_index { |row, row_num|
    row.map.with_index { |eligible, col_num|
      next false unless eligible
      if count_cardinal(seating_chart, current, row_num, col_num) < stable_range.min
        true
      elsif count_cardinal(seating_chart, current, row_num, col_num) > stable_range.max
        false
      else
        current[row_num][col_num]
      end
    }
  }
end

def count_cardinal(seating_chart, grid, row, col)
  cardinal_seats(seating_chart, grid, row, col).count { |r, c| grid[r][c] }
end

def cardinal_seats(seating_chart, grid, row, col)
  (-1..1).flat_map { |y_direction|
    (-1..1).map { |x_direction|
      next if y_direction.zero? && x_direction.zero?
      r = row + y_direction
      c = col + x_direction
      while in_grid?(grid, r, c) && !seating_chart[r][c] do
        r = r + y_direction
        c = c + x_direction
      end
      next unless in_grid?(grid, r, c)
      [r, c]
    }
  }.compact
end

def count_filled(grid)
  grid.sum { |row| row.count(&:itself) }
end

def grid_to_s(seating_chart, current)
  seating_chart.map.with_index { |row, row_num|
    row.map.with_index { |eligible, col_num|
      if eligible && current[row_num][col_num]
        '#'
      elsif eligible
        'L'
      else
        '.'
      end
    }.join
  }.join("\n")
end

def print_grid(seating_chart, current, clear: true)
  puts "\e[H\e[2J" if clear
  puts grid_to_s(seating_chart, current)
end

if $0 == __FILE__
  seating = parse_seats(ARGF.read)
  current = life(seating_chart: seating, current: empty(seating))
  loop do
    next_iteration = life(seating_chart: seating, current: current)
    break if next_iteration == current
    current = next_iteration
  end
  puts count_filled(current)

  current = life2(seating_chart: seating, current: empty(seating))
  loop do
    next_iteration = life2(seating_chart: seating, current: current)
    break if next_iteration == current
    current = next_iteration
  end
  puts count_filled(current)
end
