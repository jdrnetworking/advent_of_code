#!/usr/bin/env ruby

require 'io/console'

require_relative './computer'
require_relative './infinite_grid'

class Game
  attr_reader :code, :computer, :grid
  attr_accessor :x, :y, :state, :joystick_pos, :score
  attr_accessor :ball_x, :paddle_x, :interactive

  def initialize(code, interactive: false)
    @code = code
    @computer = Computer.new(code, self, self)
    @grid = InfiniteGrid.new(display_mapping: { nil => ' ', 0 => ' ', 1 => '█', 2 => '▒', 3 => '=', 4 => 'o' })
    @state = :x
    @interactive = interactive
    @score = 0
  end

  def to_s
    "#{grid}\n#{score}"
  end

  def shift
    puts "\e[H\e[2J#{self}"
    sleep 0.01
    if interactive
      input = get_char
    else
      input = next_move
    end
    self.joystick_pos = input
  end

  def next_move
    ball_x <=> paddle_x
  end

  def get_char
    case STDIN.getch
    when "\e"
      case STDIN.getch
      when '['
        case STDIN.getch
        when 'D' then -1
        when 'B' then 0
        when 'C' then 1
        end
      end
    end
  end

  def <<(val)
    case state
    when :x
      self.x = val
      self.state = :y
    when :y
      self.y = val
      self.state = :tile
    when :tile
      if [x, y] == [-1, 0]
        self.score = val
      else
        grid[x, y] = val
        if val == 3
          self.paddle_x = x
        elsif val == 4
          self.ball_x = x
        end
      end
      self.state = :x
    end
  end

  def run
    computer.compute!
    puts "\e[H\e[2J#{self}"
  end

  def block_count
    grid.grid.flatten.group_by(&:itself).transform_values(&:count)[2]
  end
end

if $0 == __FILE__
  code = ARGF.read.strip.split(',').map(&:to_i)
  game = Game.new(code)
  game.run
  block_count = game.block_count
  code[0] = 2
  game = Game.new(code)
  game.run
  puts
  puts "Part 1: #{block_count}"
  puts "Part 2: #{game.score}"
end
