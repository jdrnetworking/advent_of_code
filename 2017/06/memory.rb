#!/usr/bin/env ruby

require 'digest/sha1'

class Memory
  attr_accessor :memory, :previous_layouts

  def initialize(memory)
    @memory = memory
    @previous_layouts = [fingerprint_layout(memory)]
  end

  def reallocate
    catch(:step) do
      loop do
        index = fullest_bank
        count = memory[index]
        memory[index] = 0
        count.times { |i| memory[(index + i + 1) % memory.size] += 1 }
        fingerprint = fingerprint_layout(memory)
        throw(:step) if previous_layouts.include?(fingerprint)
        self.previous_layouts << fingerprint
      end
    end
  end

  def steps
    previous_layouts.size
  end

  def fullest_bank
    # sort by the inverted index to prioritize banks that come first
    memory.each_with_index.max_by { |count, index| [count, memory.size - index] }.last
  end

  def loop_size
    previous_layouts.size - previous_layouts.index(fingerprint_layout(memory))
  end

  def to_s
    '[' + memory.map(&:to_s).join(' ') + ']'
  end

  def inspect
    to_s
  end

  def fingerprint_layout(memory)
    memory.hash
  end
end

if $0 == __FILE__
  memory = Memory.new(STDIN.read.chomp.split.map { |i| Integer(i) })
  memory.reallocate
  puts "Reallocation finished at step #{memory.steps}; loop size #{memory.loop_size}"
end
