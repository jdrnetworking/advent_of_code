#!/usr/bin/env ruby

class RealCircularBuffer
  attr_accessor :buffer, :current_position, :steps

  def initialize(steps)
    @buffer = [0]
    @current_position = 0
    @steps = steps
  end

  def insert(value: buffer.size, times: 1)
    times.times do
      self.current_position = (current_position + steps) % buffer.size + 1
      buffer.insert(current_position, value)
    end
    self
  end

  def [](*args)
    buffer[*args]
  end

  def size
    buffer.size
  end

  def to_s
    buffer.map.with_index { |value, index|
      if index == current_position
        "(#{value})"
      else
        " #{value} "
      end
    }.join
  end

  def inspect
    to_s
  end
end

class FakeCircularBuffer
  attr_accessor :size, :current_position, :steps, :value_after_0

  def initialize(steps)
    @steps = steps
    reset
  end

  def insert(times = 1)
    times.times do
      self.current_position = (current_position + steps) % size + 1
      self.value_after_0 = size if current_position == 1
      self.size += 1
    end
  end

  def reset
    @size = 1
    @value_after_0 = nil
    @current_position = 0
  end
end

if $0 == __FILE__
  if ARGV.empty?
    puts "Usage: #{$0} steps"
    exit 1
  end

  steps = ARGV.shift.to_i
  insertions = 2017
  buffer = RealCircularBuffer.new(steps)
  insertions.times { buffer.insert }
  puts "After #{insertions} insertions: #{buffer[(buffer.current_position + 1) % buffer.size]}"

  insertions = 50_000_000
  buffer = FakeCircularBuffer.new(steps)
  buffer.insert(insertions)
  puts "After #{insertions} insertions, value after 0: #{buffer.value_after_0}"
end
