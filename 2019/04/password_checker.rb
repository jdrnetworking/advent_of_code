#!/usr/bin/env ruby

pw_range = Range.new(*ARGV[0].strip.split('-'))

def has_adjacent_digits?(pw)
  pw.chars.each_cons(2).any? { |i,j| i == j }
end

def monotonic?(pw)
  pw.chars.each_cons(2).all? { |i,j| i <= j }
end

def has_adjacent_digits_but_not_too_many?(pw)
  two_matches = pw.chars.each_cons(2).select { |i,j| i == j }.map(&:first).uniq
  three_matches = pw.chars.each_cons(3).select { |i,j,k| i == j && j == k }.map(&:first).uniq
  !(two_matches - three_matches).empty?
end

count1 = pw_range
  .select { |pw| has_adjacent_digits?(pw) }
  .select { |pw| monotonic?(pw) }
  .count

count2 = pw_range
  .select { |pw| has_adjacent_digits_but_not_too_many?(pw) }
  .select { |pw| monotonic?(pw) }
  .count

puts "Part 1: #{count1}"
puts "Part 2: #{count2}"
