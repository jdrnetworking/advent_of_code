#!/usr/bin/env ruby

class Santa
  attr_accessor :r, :c, :grid, :deliverers, :current_deliverer

  def initialize(deliverers = 1)
    @grid = Array.new(1) { Array.new(1, 0) }
    @deliverers = deliverers.times.map { [0, 0] }
    @deliverers.each { |r,c| @grid[r][c] = 1 }
    @current_deliverer = 0
  end

  def process(instructions)
    instructions.each do |instruction|
      process_instruction(instruction)
      self.current_deliverer = (current_deliverer + 1) % deliverers.size
    end
    self
  end

  def process_instruction(instruction)
    case instruction
    when '^'
      move_north
    when 'v'
      move_south
    when '<'
      move_west
    when '>'
      move_east
    end
    self
  end

  def visited_houses
    grid.map { |row|
      row.count { |cell| cell > 0 }
    }.sum
  end

  def width
    grid.map(&:size).max
  end

  def height
    grid.size
  end

  def move_north
    if deliverers[current_deliverer][0].zero?
      grid.unshift(Array.new(width, 0))
      deliverers.each { |d| d[0] += 1 }
    end
    deliverers[current_deliverer][0] -= 1
    r, c = deliverers[current_deliverer]
    grid[r][c] += 1
  end

  def move_south
    deliverers[current_deliverer][0] += 1
    grid.push(Array.new(width, 0)) if deliverers[current_deliverer][0] == height
    r, c = deliverers[current_deliverer]
    grid[r][c] += 1
  end

  def move_east
    deliverers[current_deliverer][1] += 1
    grid.each { |row| row.push(0) } if deliverers[current_deliverer][1] == width
    r, c = deliverers[current_deliverer]
    grid[r][c] += 1
  end

  def move_west
    if deliverers[current_deliverer][1].zero?
      grid.each { |row| row.unshift(0) }
      deliverers.each { |d| d[1] += 1 }
    end
    deliverers[current_deliverer][1] -= 1
    r, c = deliverers[current_deliverer]
    grid[r][c] += 1
  end

  def to_s
    grid.map { |row|
      row.map { |cell|
        ' %3d ' % cell
      }.join
    }.join("\n")
  end

  def inspect
    to_s
  end
end

if $0 == __FILE__
  if ARGV.empty?
    puts "Usage: #{File.basename($0)} moves.txt"
    exit 1
  end

  ARGF.readlines.each do |line|
    moves = line.chomp.chars

    santa_1 = Santa.new
    santa_1.process(moves)
    puts "With 1 santa: #{santa_1.visited_houses}"

    santa_2 = Santa.new(2)
    santa_2.process(moves)
    puts "With 2 santas: #{santa_2.visited_houses}"
  end
end
