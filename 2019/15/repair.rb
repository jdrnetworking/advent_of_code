#!/usr/bin/env ruby

require 'io/console'
require_relative './lib/computer'
require_relative './lib/infinite_grid'

class Repair
  attr_reader :code, :computer, :grid
  attr_accessor :x, :y, :interactive, :oxygen_x, :oxygen_y, :step_sleep

  def initialize(code, interactive: false, step_sleep: 0.01)
    @code = code
    @interactive = interactive
    @in, @out = Queue.new, Queue.new
    @computer = Computer.new(code, @in, @out)
    @grid = InfiniteGrid.new(display_mapping: {wall: '█', oxygen: 'X'})
    @x, @y = 0, 0
    @step_sleep = step_sleep
    grid[x,y] = 0
  end

  def run
    @thread = Thread.new { computer.compute! }
    loop do
      display([0,0] => '+', [x,y] => '.')
      direction = interactive ? get_char : next_move
      break if direction == :quit
      result = move(direction)
      update_position(direction)
      break if grid[x,y] == 0
      if result == 2
        self.oxygen_x = x
        self.oxygen_y = y
        break
      end
      sleep step_sleep
    end
    display([0,0] => '+', [x,y] => 'O')
    oxygen_distance = grid[x,y]

    grid.gsub! { |x,y,value|
      Integer === value ? nil : value
    }
    grid[x,y] = 0

    loop do
      display([0,0] => '+', [oxygen_x, oxygen_y] => 'O', [x,y] => '.')
      direction = next_move
      result = move(direction)
      update_position(direction)
      break if grid[x,y] == 0
      sleep step_sleep
    end
    display([0,0] => '+', [oxygen_x, oxygen_y] => 'O', [x,y] => '.')
    furthest = grid.to_a.flatten.select { |v| v.is_a?(Integer) }.max
    puts "Part 1: #{oxygen_distance}"
    puts "Part 2: #{furthest}"
  end

  def display(overrides)
    print "\e[H\e[2J"
    overrides = { [0,0] => '+' }
    if oxygen_x && oxygen_y
      overrides[[oxygen_x, oxygen_y]] = 'O'
    end
    puts "#{grid.to_s(overrides: overrides)}"
  end

  def next_move
    # see what's around
    probe

    # always try an unknown path first
    return possible_moves.detect { |_,v| v.nil? }.first if possible_moves.values.any?(&:nil?)

    # if there are no unknown paths, backtrack
    possible_moves.min_by { |dir,val| val }.first
  end

  def probe
    (1..4).each do |direction|
      result = move(direction)
      if result.zero?
        note_wall_in_direction(direction)
      else
        move(opposite_of(direction))
      end
    end
  end

  def possible_moves
    surroundings.reject { |_,v| v == :wall }
  end

  def surroundings
    {
      1 => grid[x,y+1],
      2 => grid[x,y-1],
      3 => grid[x-1,y],
      4 => grid[x+1,y]
    }
  end

  def opposite_of(direction)
    {
      1 => 2,
      2 => 1,
      3 => 4,
      4 => 3
    }[direction]
  end

  def move(direction)
    @in << direction
    @out.shift
  end

  def update_position(direction)
    current_count = grid[x, y]
    case direction
    when 1
      self.y += 1
    when 2
      self.y -= 1
    when 3
      self.x -= 1
    when 4
      self.x += 1
    end
    grid[x,y] ||= current_count + 1
  end

  def note_wall_in_direction(direction)
    case direction
    when 1
      grid[x,y+1] = :wall
    when 2
      grid[x,y-1] = :wall
    when 3
      grid[x-1,y] = :wall
    when 4
      grid[x+1,y] = :wall
    end
  end

  def get_char
    case STDIN.getch
    when "\e"
      case STDIN.getch
      when '['
        case STDIN.getch
        when 'A' then 1 # up
        when 'B' then 2 # down
        when 'D' then 3 # left
        when 'C' then 4 # right
        end
      end
    when 'q' then :quit
    end
  end
end

if $0 == __FILE__
  code = ARGF.read.strip.split(',').map(&:to_i)
  repair = Repair.new(code)
  repair.run
end
