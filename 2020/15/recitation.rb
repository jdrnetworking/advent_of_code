#!/usr/bin/env ruby

def way_the_first(numbers, times)
  nums = numbers.dup
  (times - nums.size).times do
      last = nums[0..-2].rindex(nums.last) || (nums.size - 1)
      nums.push(nums.size - last - 1)
  end
  nums.last
end

def way_the_second(numbers, times)
  h = numbers.map.with_index.to_h
  next_number = 0 # assumes last number hasn't been seen before, works with given inputs
  (times - numbers.size - 1).times.with_index(numbers.size) do |_, current|
    if h.key?(next_number)
      h[next_number], next_number = current, current - h[next_number]
    else
      h[next_number], next_number = current, 0
    end
  end
  next_number
end

if $0 == __FILE__
  inputs = ARGF.each_line.map { |line|
    line.chomp.split(',').map(&:to_i)
  }
  inputs.each do |input|
    puts way_the_second(input, 2020)
    puts way_the_second(input, 30000000)
  end
end
