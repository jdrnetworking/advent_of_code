#!/usr/bin/env ruby

class KnotHash
  SUFFIX = [17, 31, 73, 47, 23].freeze

  attr_accessor :list, :current_position, :skip_size

  def initialize(length = 256)
    @list = (0...length).to_a
    @current_position = 0
    @skip_size = 0
  end

  def process(length)
    reverse_segment(current_position, length)
    self.current_position = (current_position + length + skip_size) % list.length
    self.skip_size += 1
    self
  end

  def reverse_segment(position, length)
    if position + length <= list.length
      list[position, length] = list[position, length].reverse
    else
      segment = list[position, list.length - position] + list[0, (position + length) % list.length]
      segment.reverse!
      list[position, list.length - position] = segment[0, list.length - position]
      list[0, length - (list.length - position)] = segment[list.length - position, length - (list.length - position)]
    end
  end

  def dense_hash(chunk_size: 16)
    list.each_slice(chunk_size).map { |chunk|
      chunk.inject(&:^)
    }
  end

  def to_hex
    dense_hash.map { |i| i.to_s(16).rjust(2, '0') }.join
  end

  def checksum(lengths)
    lengths.each do |length|
      process(length)
    end
    list.take(2).inject(&:*)
  end

  def digest(lengths, rounds: 64)
    rounds.times do
      (lengths + SUFFIX).each do |length|
        process(length)
      end
    end
    to_hex
  end

  def self.digest(input)
    new.digest(input.bytes)
  end

  def to_s
    list.map.with_index { |elem, index|
      if index == current_position
        "[#{elem}]"
      else
        elem.to_s
      end
    }.join(' ')
  end

  def inspect
    to_s
  end
end

if $0 == __FILE__
  # ./knot_hash.rb [list_size = 256] input

  list_size = ARGV.size > 1 ? ARGV.shift.to_i : 256
  ARGF.each_line do |input|
    input.chomp!
    part_1_lengths = input.split(',').map(&:to_i)
    hash = KnotHash.new(list_size)
    puts "Checksum: #{hash.checksum(part_1_lengths)}"

    if (list_size % 16).zero?
      part_2_lengths = input.each_byte.to_a
      hash = KnotHash.new(list_size)
      puts "Hash: #{hash.digest(part_2_lengths)}"
    end
  end
end
