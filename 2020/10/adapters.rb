#!/usr/bin/env ruby

input = ARGF.read
joltages = input
  .split
  .map(&:to_i)
  .sort
  .unshift(0)
  .tap { |a| a.push(a.last + 3) }

differences = joltages
  .each_cons(2)
  .map { |a,b| b-a }

# Part 1
puts differences
  .tally
  .values
  .reduce(:*)

# Part 2
puts differences
  .chunk(&:itself) # separate the 1's from the 3's
  .reject { |chunk| chunk.first == 3 } # keep only the 1's; 3's represent where there are no other combinations
  .map(&:last)
  .map(&:size) # how many 1's in a row
  .map { |size|
    case size
    when 1 then 1 # [1] can't be substituted with anything else, so only 1 combination
    when 2 then 2 # [1,1] can be substituted with [2] - that's 2 combinations
    else # 7 combinations from [1,1,1], 12 combinations from [1,1,1,1], etc
      2 ** (size - 1) - (size - 3) ** 2
    end
  }
  .reduce(:*)
