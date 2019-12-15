#!/usr/bin/env ruby

require_relative './lib/computer'

memory = ARGF.read.strip.split(',').map(&:to_i)

memory[1] = 12
memory[2] = 2

computer = Computer.new(memory, [], [])
computer.compute!
puts "Part 1: #{computer.memory[0]}"

(0..99).each do |noun|
  (0..99).each do |verb|
    memory[1] = noun
    memory[2] = verb

    computer = Computer.new(memory, [], [])
    computer.compute!

    next unless computer.memory[0] == 19690720

    puts "Part 2: #{100*noun + verb}"
    exit
  end
end
