#!/usr/bin/env ruby

input = ARGF.read.split(/(?:\r?\n){2}/)
puts input.map { |t| (t.chars & ('a'..'z').to_a).size }.sum
puts input.map { |t| t.split(/\r?\n/).map(&:chars).inject(:&).size }.sum
