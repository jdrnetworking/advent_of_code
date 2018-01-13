#!/usr/bin/env ruby

if ARGV.size < 2
  puts "Usage: #{File.basename $0} input iterations"
  exit 1
end

input = ARGV.shift
iterations = ARGV.shift.to_i

output = iterations.times.inject(input) { |m,_|
  m.chars.chunk(&:itself).map { |val,vals| "#{vals.size}#{val}" }.join
}
puts "After #{iterations} iterations, size: #{output.size}"
