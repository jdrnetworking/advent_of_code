#!/usr/bin/env ruby

require 'pry-byebug'
require_relative './lib/bios'
require_relative './lib/computer'
require_relative './lib/infinite_grid'

if $0 == __FILE__
  code = ARGF.read.strip.split(',').map(&:to_i)
  grid = InfiniteGrid.new(inverted: true, display_mapping: {0 => '.', 1 => '#'})
  computer = Computer.new(code)

  def get(x,y,computer)
    computer.inputs << x << y
    computer.reboot!
    computer.outputs.shift
  end
  (0..49).each do |y|
    (0..49).each do |x|
      grid[x, y] = get(x, y, computer)
    end
  end
  puts "Part 1: #{grid.specified_cell_count(values: [1])}"
  x = x_offset = (0..49).detect { |x| grid[x,49] == 1 }
  y = 50
  target = 100
  loop do
    loop do # find the start of this row
      grid[x, y] = get(x, y, computer)
      x += 1
      break if grid[x-1,y] == 1
    end
    break if grid[x+target-2,y-target+1] == 1
    x_offset = x - 1
    loop do # find the end of this row
      grid[x, y] = get(x, y, computer)
      x += 1
      break if grid[x-1,y] == 0
    end
    y += 1
    x = x_offset
  end
  grid[x-1,y-9] = 2
  puts "Part 2: #{10000*(x-1) + (y-9)}"
  # 6841027 too high
end
