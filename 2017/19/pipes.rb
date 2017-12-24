#!/usr/bin/env ruby

class Route
  attr_accessor :grid, :height, :width

  def initialize(grid)
    @grid = grid
    @height = grid.size
    @width = grid.map(&:size).max
  end

  def out_of_bounds?(row, col)
    row < 0 || row >= height ||
      col < 0 || col >= width
  end

  def inspect
    to_s
  end

  def to_s
    grid.map { |row| row.join }.join("\n")
  end

  def entry_point
    [0, grid[0].index('|')]
  end

  def [](row, col)
    grid[row].fetch(col, ' ')
  end

  def self.from_text(input)
    new(input.split(/[\r\n]+/).map { |row| row.chars })
  end
end

class Packet
  attr_accessor :route, :row, :col, :direction, :collection, :steps

  def initialize(route:, direction: :down)
    @route = route
    @row, @col = route.entry_point
    @direction = direction
    @collection = []
    @steps = 0
  end

  def run
    step until end_of_the_line?
    { collection: collection, steps: steps }
  end

  def step
    move
    process_cell
    self
  end

  def move
    case direction
    when :up
      self.row -= 1
    when :down
      self.row += 1
    when :left
      self.col -= 1
    when :right
      self.col += 1
    end
    self.steps += 1
  end

  def process_cell
    case route[row, col]
    when /[A-Z]/
      collection << route[row, col]
    when '+'
      turn
    end
  end

  def turn
    if [:up, :down].include?(direction)
      if route[row, col - 1] =~ /[A-Z-]/
        self.direction = :left
      elsif route[row, col + 1] =~ /[A-Z-]/
        self.direction = :right
      else
        raise "?!? @#{row},#{col} heading #{direction}"
      end
    else
      if route[row - 1, col] =~ /[A-Z|]/
        self.direction = :up
      elsif route[row + 1, col] =~ /[A-Z|]/
        self.direction = :down
      else
        raise "?!? @#{row},#{col} heading #{direction}"
      end
    end
  end

  def end_of_the_line?
    route.out_of_bounds?(row, col) || route[row, col] == ' '
  end
end

if $0 == __FILE__
  route = Route.from_text(ARGF.read.chomp)
  packet = Packet.new(route: route)
  result = packet.run
  puts "Collection: #{result[:collection].join}, Total steps: #{result[:steps]}"
end
