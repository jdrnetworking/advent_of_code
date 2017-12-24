#!/usr/bin/env ruby

class Cluster
  attr_accessor :grid, :infection_count

  def initialize(grid, width: nil, height: nil)
    @grid = grid.map { |row| row.dup }
    if height && self.height < height
      loop do
        grow_up
        break if self.height >= height
        grow_down
        break if self.height >= height
      end
    end
    if width && self.width < width
      loop do
        grow_left
        break if self.width >= width
        grow_right
        break if self.width >= width
      end
    end
    @infection_count = 0
  end

  def [](x,y)
    grid[y][x]
  end

  def toggle(x, y, ruleset)
    new_value = ruleset[grid[y][x]]
    if new_value == '#'
      self.infection_count += 1
    end
    grid[y][x] = new_value
  end

  def width
    grid.map(&:size).max
  end

  def height
    grid.size
  end

  def grow_right
    grid.each { |row| row.push('.') }
  end

  def grow_left
    grid.each { |row| row.unshift('.') }
  end

  def grow_up
    grid.unshift(grid.first.map { '.' })
  end

  def grow_down
    grid.push(grid.last.map { '.' })
  end

  def print(x = nil, y = nil, extra_info = '')
    (extra_info.empty? ? '' : "#{extra_info}\n") +
    grid.map.with_index { |row, _y|
      row.map.with_index { |col, _x|
        if x == _x && y == _y
          "[#{grid[_y][_x]}]"
        else
          " #{grid[_y][_x]} "
        end
      }.join
    }.join("\n")
  end

  def inspect
    print
  end
end

class Carrier
  attr_accessor :cluster, :x, :y, :direction, :toggle_rules, :movement_rules

  def initialize(cluster, ruleset)
    @cluster = cluster
    @x = cluster.width / 2
    @y = cluster.height / 2
    @direction = :up
    @toggle_rules = ruleset[:toggle_rules]
    @movement_rules = ruleset[:movement_rules]
  end

  def burst
    turn
    toggle
    move
    self
  end

  def turn
    send movement_rules[cluster[x, y]]
  end

  def toggle
    cluster.toggle(x, y, toggle_rules)
  end

  def move
    send "move_#{direction}"
  end

  def move_up
    if y.zero?
      cluster.grow_up
    else
      self.y -= 1
    end
  end

  def move_down
    if y == cluster.height - 1
      cluster.grow_down
    end
    self.y += 1
  end

  def move_right
    if x == cluster.width - 1
      cluster.grow_right
    end
    self.x += 1
  end

  def move_left
    if x.zero?
      cluster.grow_left
    else
      self.x -= 1
    end
  end

  def turn_right
    self.direction = directions[(directions.index(direction) + 1) % 4]
  end

  def turn_left
    self.direction = directions[(directions.index(direction) + 3) % 4]
  end

  def turn_around
    self.direction = directions[(directions.index(direction) + 2) % 4]
  end

  def do_nothing
  end

  def directions
    %i(up right down left).freeze
  end

  def to_s
    cluster.print(x, y, direction)
  end

  def inspect
    to_s
  end

  def self.rules_1
    {
      toggle_rules: {
        '#' => '.',
        '.' => '#'
      },
      movement_rules: {
        '.' => :turn_left,
        '#' => :turn_right
      }
    }
  end

  def self.rules_2
    {
      toggle_rules: {
        '#' => 'F',
        '.' => 'W',
        'W' => '#',
        'F' => '.'
      },
      movement_rules: {
        '.' => :turn_left,
        'W' => :do_nothing,
        '#' => :turn_right,
        'F' => :turn_around
      }
    }
  end
end

if $0 == __FILE__
  if ARGV.empty?
    puts "Usage: #{$0} input_file"
    exit 1
  end

  grid = ARGF.readlines.map { |line| line.chomp.chars }
  cluster = Cluster.new(grid)
  carrier = Carrier.new(cluster, Carrier.rules_1)
  10000.times { carrier.burst }
  puts "Part 1: #{cluster.infection_count} infections"

  cluster = Cluster.new(grid)
  carrier = Carrier.new(cluster, Carrier.rules_2)
  10000000.times { carrier.burst }
  puts "Part 2: #{cluster.infection_count} infections"
end
