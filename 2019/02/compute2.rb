#!/usr/bin/env ruby

initial_memory = ARGF.read.strip.split(',').map(&:to_i)

(0..99).each do |noun|
  (0..99).each do |verb|
    memory = initial_memory.dup

    memory[1] = noun
    memory[2] = verb

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

    next unless memory[0] == 19690720

    puts 100*noun + verb
    exit
  end
end
