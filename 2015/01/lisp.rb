#!/usr/bin/env ruby

module Lisp
  module_function

  def count(input)
    counts = input.chars.group_by(&:itself).transform_values(&:count)
    counts.fetch('(', 0) - counts.fetch(')', 0)
  end

  def basement(input)
    input.chars.inject([0,0]) { |m,char|
      m[1] += 1
      m[0] += (char == '(' ? 1 : -1)
      break m[1] if m[0] < 0
      m
    }
  end
end

if $0 == __FILE__
  if ARGV.empty?
    puts "Usage: #{File.basename($0)} input.txt"
    exit 1
  end

  input = ARGF.read.chomp
  puts "Count: #{Lisp.count(input)}"
  puts "Basement in #{Lisp.basement(input)} moves"
end
