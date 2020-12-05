#!/usr/bin/env ruby

ids = ARGF.map { |line| line.tr('FBLR', '0101').to_i(2) }
puts ids.max
puts ids.sort.each_cons(2).detect { |m, n| n - m == 2 }.first + 1
