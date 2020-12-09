#!/usr/bin/env ruby

def first_error(preamble, numbers)
  numbers.each_cons(preamble + 1).detect { |set|
    set[0..-2].combination(2).detect { |combo|
      combo.sum == set.last
    }.nil?
  }.last
end

def contiguous_sum(numbers, sum)
  numbers.each_with_index { |number, start_index|
    end_index = ((start_index + 1)..(numbers.size - 1)).detect { |end_index|
      numbers[start_index..end_index].sum == sum
    } and return numbers[start_index..end_index]
  }
  nil
end

if $0 == __FILE__
  input = ARGF.each_line.map(&:chomp)
  preamble = input.shift[/Preamble: (\d+)/, 1].to_i
  numbers = input.map(&:to_i)
  invalid_number = first_error(preamble, numbers)
  puts invalid_number
  set = contiguous_sum(numbers, invalid_number)
  puts set.min + set.max
end
