#!/usr/bin/env ruby

memory = ARGF.read.strip.split(',').map(&:to_i)

def decode_instruction(instruction)
  parts = instruction.to_s.chars.reverse
  opcode = (parts.shift + (parts.shift || '0')).reverse.to_i
  [opcode, parts.map(&:to_i)]
end

ip = 0
loop do
  instruction = memory[ip]
  opcode, parameter_modes = decode_instruction(instruction)
  case opcode
  when 1
    params = (1..2).map { |i| val = memory[ip + i]; parameter_modes[i - 1] == 1 ? val : memory[val] }
    memory[memory[ip + 3]] = params[0] + params[1]
    ip += 4
  when 2
    params = (1..2).map { |i| val = memory[ip + i]; parameter_modes[i - 1] == 1 ? val : memory[val] }
    memory[memory[ip + 3]] = params[0] * params[1]
    ip += 4
  when 3
    print "> "
    memory[memory[ip + 1]] = STDIN.gets.strip.to_i
    ip += 2
  when 4
    val = memory[ip + 1]
    param = parameter_modes[0] == 1 ? val : memory[val]
    puts param
    ip += 2
  when 5
    params = (1..2).map { |i| val = memory[ip + i]; parameter_modes[i - 1] == 1 ? val : memory[val] }
    if params[0].nonzero?
      ip = params[1]
    else
      ip += 3
    end
  when 6
    params = (1..2).map { |i| val = memory[ip + i]; parameter_modes[i - 1] == 1 ? val : memory[val] }
    if params[0].zero?
      ip = params[1]
    else
      ip += 3
    end
  when 7
    params = (1..2).map { |i| val = memory[ip + i]; parameter_modes[i - 1] == 1 ? val : memory[val] }
    memory[memory[ip + 3]] = params[0] < params[1] ? 1 : 0
    ip += 4
  when 8
    params = (1..2).map { |i| val = memory[ip + i]; parameter_modes[i - 1] == 1 ? val : memory[val] }
    memory[memory[ip + 3]] = params[0] == params[1] ? 1 : 0
    ip += 4
  when 99
    break
  else
    raise ArgumentError, "Unknown Instruction: #{memory[ip]} at location #{ip}. Memory:\n#{memory.inspect}"
  end
end
