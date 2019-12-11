#!/usr/bin/env ruby

require_relative './computer'
require_relative './infinite_grid'

class Robot
  DIRECTIONS = %w[Up Right Down Left]

  attr_accessor :x, :y, :direction
  attr_reader :grid

  def initialize(grid)
    @grid = grid
    @x, @y = 0, 0
    @direction = 0
    @painting = true
  end

  def shift
    grid[x,y] || 0
  end

  def <<(val)
    if painting?
      grid[x,y] = val
    else
      self.direction = (direction + (val * 2 - 1)) % 4
      move!
    end
    @painting = !painting?
    self
  end

  def move!
    case direction
    when 0
      self.y += 1
    when 1
      self.x += 1
    when 2
      self.y -= 1
    when 3
      self.x -= 1
    end
  end

  def painting?
    @painting
  end

  def painted_cell_count
    grid.specified_cell_count
  end
end

if $0 == __FILE__
  grid = InfiniteGrid.new
  robot = Robot.new(grid)
  initial_memory = ARGF.read.strip.split(',').map(&:to_i)
  computer = Computer.new(initial_memory, robot, robot)
  computer.compute!
  puts "Part 1: #{robot.painted_cell_count}"
  grid = InfiniteGrid.new
  grid[0,0] = 1
  robot = Robot.new(grid)
  computer = Computer.new(initial_memory, robot, robot)
  computer.compute!
  puts "Part 2:"
  puts grid.to_s({nil => ' ', 0 => ' ', 1 => '█'})
end
