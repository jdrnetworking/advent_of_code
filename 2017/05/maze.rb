#!/usr/bin/env ruby

class Maze
  attr_accessor :instructions, :instruction_counter, :step

  def initialize(instructions)
    @instructions = instructions
    @instruction_counter = 0
    @step = 0
  end

  def next
    offset = instructions[instruction_counter]
    instructions[instruction_counter] += delta(offset)
    self.instruction_counter += offset
    self.step += 1
    self
  end

  def delta(instruction)
    1
  end

  def out_of_bounds?
    instruction_counter < 0 || instruction_counter >= instructions.length
  end

  def inspect
    "#{'%4d' % step}: [" + instructions.map.with_index { |instruction, index|
      index == instruction_counter ? "<#{instruction}>" : " #{instruction} "
    }.join(' ') + ']'
  end

  def to_s
    inspect
  end
end

class Maze2 < Maze
  def delta(instruction)
    instruction >= 3 ? -1 : 1
  end
end

if $0 == __FILE__
  instructions = STDIN.read.chomp.split.map { |instruction| Integer(instruction) }
  maze = Maze2.new(instructions)
  puts maze if ARGV.first == '-d'
  until maze.out_of_bounds?
    maze.next
    puts maze if ARGV.first == '-d'
  end
  puts "Out of bounds in #{maze.step} steps"
end
