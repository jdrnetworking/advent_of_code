#!/usr/bin/env ruby

memory = ARGF.read.strip.split(',').map(&:to_i)

memory[1] = 12
memory[2] = 2

ip = 0
loop do
  case memory[ip]
  when 1
    memory[memory[ip + 3]] = memory[memory[ip + 1]] + memory[memory[ip + 2]]
    ip += 4
  when 2
    memory[memory[ip + 3]] = memory[memory[ip + 1]] * memory[memory[ip + 2]]
    ip += 4
  when 99
    break
  else
    raise ArgumentError, "Unknown Instruction: #{memory[ip]} at location #{ip}. Memory:\n#{memory.inspect}"
  end
end

puts memory[0]
