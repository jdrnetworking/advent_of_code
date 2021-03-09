#!/usr/bin/env ruby

def parse(input)
  input.split(/\n/).map(&:to_i)
end

def derive_loop_size(key)
  i = 1
  n = 1
  loop do
    n *= 7
    n %= 20201227
    break i if n == key
    i += 1
  end
end

def perform_rounds(subject, rounds)
  rounds.times.reduce(1) { |n, _|
    n *= subject
    n %= 20201227
  }
end

if $0 == __FILE__
  public_keys = parse(ARGF.read)
  loop_sizes = public_keys.map { |key| derive_loop_size(key) }
  key = perform_rounds(public_keys.first, loop_sizes.last)
  puts key
end
