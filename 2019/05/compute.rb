#!/usr/bin/env ruby

require_relative './lib/computer'

class ManualHarness
  def shift
    print "> "
    STDIN.gets.strip.to_i
  end

  def <<(val)
    puts val
  end
end

if $0 == __FILE__
  memory = ARGF.read.strip.split(',').map(&:to_i)
  harness = ManualHarness.new
  computer = Computer.new(memory, harness, harness)
  computer.compute!
end
