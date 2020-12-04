#!/usr/bin/env ruby

def parse(input)
  input
    .split(/[\r\n]+/)
    .map { |line|
      line.chars.map { |char|
        case char
        when '.' then 0
        when '#' then 1
        else raise ArgumentError, "Unexpected character '#{char}'"
        end
      }
    }
end

def on_grid?(grid, row, col)
  row < grid.size && col < grid[row].size
end

def count_trees(grid, over, down)
  row, col = 0, 0
  count = 0
  while on_grid?(grid, row, col) do
    count += grid[row][col]
    col = (col + over) % grid.first.size
    row += down
  end
  count
end

grid = parse(ARGF.read)

puts count_trees(grid, 3, 1)

slopes = [
  [1, 1],
  [3, 1],
  [5, 1],
  [7, 1],
  [1, 2],
]

puts slopes.map { |over, down|
  count_trees(grid, over, down)
}.inject(:*)
