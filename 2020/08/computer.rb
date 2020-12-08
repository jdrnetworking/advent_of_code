#!/usr/bin/env ruby

def parse(input)
  instruction = /(\w+) ([+-]\d+)/
  input.split(/\r?\n/).map { |line|
    instruction.match(line).captures.tap { |cap|
      cap[1] = cap[1].to_i
    }
  }
end

def run(instructions)
  registers = {
    pc: 0,
    acc: 0,
  }
  seen = Array.new(instructions.size, false)
  until seen[registers[:pc]] || registers[:pc] >= instructions.size
    seen[registers[:pc]] = true
    execute(instructions, registers)
  end
  registers
end

def execute(instructions, registers)
  instruction, param = instructions[registers[:pc]]
  case instruction
  when 'acc'
    registers[:acc] += param
    registers[:pc] += 1
  when 'jmp'
    registers[:pc] += param
  when 'nop'
    registers[:pc] += 1
  when 'jmp'
  else raise ArgumentError, "Unexpected instruction: '#{instruction}'"
  end
  registers
end

def run_with_swapped_instrucion(instructions, index)
  swapped_instructions = instructions.map.with_index { |instruction, i|
    if index == i
      [
        case instruction.first
        when 'jmp' then 'nop'
        when 'nop' then 'jmp'
        else instruction.first
        end,
        instruction.last
      ]
    else
      instruction
    end
  }
  registers = run(swapped_instructions)
end

if $0 === __FILE__
  instructions = parse(ARGF.read)
  registers = run(instructions)
  puts registers[:acc]

  instructions.size.times do |index|
    next if instructions[index].first == 'acc'
    registers = run_with_swapped_instrucion(instructions, index)
    if registers[:pc] >= instructions.size
      puts registers[:acc]
      break
    end
  end
end
