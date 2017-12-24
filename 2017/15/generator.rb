#!/usr/bin/env ruby

class Generator
  attr_accessor :factor, :value, :dividend, :mod

  def initialize(factor, starting_value, mod = 1)
    @factor = factor
    @value = starting_value
    @dividend = 2147483647
    @mod = mod
  end

  def next
    loop do
      self.value = (value * factor) % dividend
      break if (value % mod).zero?
    end
    value
  end
end

class Judgerator
  attr_accessor :generators, :match_size

  def initialize(*generators)
    @generators = generators
    @match_size = 0
  end

  def next(count = 1)
    count.times do
      self.match_size += 1 if match?(*generators.map(&:next))
    end
    match_size
  end

  def match?(*values)
    values.map { |value|
      value & 0xFFFF
    }.uniq.size == 1
  end
end

if $0 == __FILE__
  gen_1_seed = ARGV.shift
  gen_2_seed = ARGV.shift

  generators = [
    Generator.new(16807, Integer(gen_1_seed)),
    Generator.new(48271, Integer(gen_2_seed))
  ]
  judge = Judgerator.new(*generators)
  40_000_000.times do
    judge.next
  end
  puts "#{generators.map(&:value).join(', ')}, #{judge.match_size}"

  generators = [
    Generator.new(16807, Integer(gen_1_seed), 4),
    Generator.new(48271, Integer(gen_2_seed), 8)
  ]
  judge = Judgerator.new(*generators)
  5_000_000.times do
    judge.next
  end
  puts "#{generators.map(&:value).join(', ')}, #{judge.match_size}"
end
