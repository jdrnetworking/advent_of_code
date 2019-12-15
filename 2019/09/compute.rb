#!/usr/bin/env ruby

require_relative './lib/computer'

if $0 == __FILE__
  memory = ARGF.readlines.map(&:strip).first
  memory = memory.split(',').map(&:to_i)

  computer = Computer.new(memory, [1], [])
  computer.compute!
  puts "Part 1: #{computer.outputs}"

  computer = Computer.new(memory, [2], [])
  computer.compute!
  puts "Part 2: #{computer.outputs}"
end
