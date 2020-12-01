#!/usr/bin/env ruby

numbers = ARGF.each_line.map(&:to_i)
puts numbers.combination(2).detect { |d| d.inject(:+) == 2020 }.inject(:*)
puts numbers.combination(3).detect { |d| d.inject(:+) == 2020 }.inject(:*)
