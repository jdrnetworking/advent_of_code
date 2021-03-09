#!/usr/bin/env ruby

def matcher
  /(?:(\d+)\r?\n)?((?:.+,?)*)/
end

def parse(input)
  matcher.match(input).captures
end

def relevant_busses_with_offsets(list)
  bus_ids_with_offsets = list.split(',').map.with_index { |bus_id, offset|
    next if bus_id == 'x'
    [bus_id.to_i, offset]
  }.compact
end

def extended_euclidean(m, n)
  q = [ nil, nil]
  r = [m, n]
  s = [1, 0]
  t = [0, 1]
  loop do
    q.push(r[-2] / r.last)
    r.push(r[-2] % r.last)
    s.push(s[-2] - q.last * s.last)
    t.push(t[-2] - q.last * t.last)
    break if r.last == 0
  end
  [s[-2], t[-2]]
end

def extended_euclidean_with_offset(m, n, offset)
  s, t = extended_euclidean(m, n)
  s *= -offset
  t *= offset
  while s.negative? || t.negative?
    s += n
    t += m
  end
  [s, t]
end

if $0 == __FILE__
  start, busses = parse(ARGF.read)
  bus_ids_with_offsets = relevant_busses_with_offsets(busses)
  bus_ids = bus_ids_with_offsets.map(&:first)

  if start
    start = start.to_i
    wait, index = bus_ids.map.with_index { |bus, index| [bus - (start % bus), index] }.min_by(&:first)
    puts wait * bus_ids[index]
  end

  first_bus, *other_busses = bus_ids
  tallies = bus_ids_with_offsets[1..-1].map { |bus, offset|
    extended_euclidean_with_offset(first_bus, bus, offset).first
  }
  require 'pry'
  binding.pry

  exit
  loop do
    tallies.size.times do |i|
      tallies[i] += other_busses[i] * ((tallies.max - tallies[i]) / other_busses[i].to_f).ceil
    end
    break if tallies.uniq.size == 1
  end
  puts first_bus * tallies.first
end
