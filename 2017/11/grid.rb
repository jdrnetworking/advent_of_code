#!/usr/bin/env ruby

class Grid
  DIRECTIONS = %w(n ne se s sw nw).freeze
  OPPOSITE_DIRECTIONS = DIRECTIONS.take(DIRECTIONS.size / 2).map.with_index { |direction, i|
    [direction, DIRECTIONS[i + DIRECTIONS.size / 2]]
  }
  ADJACENT_DIRECTIONS = DIRECTIONS.map.with_index { |direction, i|
    [direction, DIRECTIONS[(i + 1) % DIRECTIONS.size], DIRECTIONS[(i + 2) % DIRECTIONS.size]]
  }

  attr_accessor :steps

  def initialize(steps)
    @steps = steps.is_a?(String) ? steps.split(',') : steps
  end

  def to_s
    "#{steps.size} steps: [#{steps.take(5).join(', ')}#{'...' if steps.size > 5}]"
  end

  def inspect
    to_s
  end

  def count_directions(steps)
    steps.group_by { |direction|
      direction
    }.each_with_object(DIRECTIONS.each_with_object({}) { |d,o| o[d] = 0 }) { |(d,ds),o|
      o[d] = ds.size
    }
  end

  def reduce_opposites(grid, d1, d2)
    magnitude = (grid[d1] - grid[d2]).abs
    direction = grid[d1] > grid[d2] ? d1 : d2
    grid[direction] = magnitude
    grid[direction == d1 ? d2 : d1] = 0
    grid
  end

  def reduce_semiadjacent(grid, d1, d2, d3)
    magnitude = [grid[d1], grid[d3]].min
    grid[d1] -= magnitude
    grid[d3] -= magnitude
    grid[d2] += magnitude
    grid
  end

  def reduce(direction_counts)
    _steps = direction_counts.dup
    last_steps = _steps.dup
    loop do
      OPPOSITE_DIRECTIONS.each do |d1, d2|
        reduce_opposites(_steps, d1, d2)
      end
      ADJACENT_DIRECTIONS.each do |d1, d2, d3|
        reduce_semiadjacent(_steps, d1, d2, d3)
      end
      break if _steps == last_steps
      last_steps = _steps.dup
    end
    _steps
  end

  def steps_away(direction_counts = count_directions(steps))
    reduce(direction_counts).values.sum
  end

  def furthest_steps_away
    high_water_mark = 0
    counts = DIRECTIONS.each_with_object({}) { |d,o| o[d] = 0 }
    steps.each do |direction|
      counts[direction] += 1
      distance = steps_away(counts)
      high_water_mark = distance if distance > high_water_mark
    end
    high_water_mark
  end
end

if $0 == __FILE__
  ARGF.each_line do |line|
    grid = Grid.new(line.chomp)
    puts "#{grid}: #{grid.steps_away} steps away, furthest: #{grid.furthest_steps_away}"
  end
end
