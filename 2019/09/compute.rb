#!/usr/bin/env ruby

require 'pry-byebug'

class Computer
  attr_reader :memory, :inputs, :outputs, :name
  attr_accessor :relative_base, :ip

  def initialize(memory, inputs, outputs, name: nil)
    @memory = memory.dup
    @inputs = inputs
    @outputs = outputs
    @name = name || rand(1000)
    @relative_base = 0
    @ip = 0
  end

  def compute!
    loop do
      instruction = memory[ip]
      opcode, parameter_modes = decode_instruction(instruction)
      case opcode
      when 1 # add
        params = decode_params(2, parameter_modes)
        write(params[0] + params[1], 2, parameter_modes)
        self.ip += 4
      when 2 # mul
        params = decode_params(2, parameter_modes)
        write(params[0] * params[1], 2, parameter_modes)
        self.ip += 4
      when 3 # input
        write(inputs.shift, 0, parameter_modes)
        self.ip += 2
      when 4 # output
        params = decode_params(1, parameter_modes)
        outputs << params[0]
        self.ip += 2
      when 5 # jnz
        params = decode_params(2, parameter_modes)
        if params[0].nonzero?
          self.ip = params[1]
        else
          self.ip += 3
        end
      when 6 # jz
        params = decode_params(2, parameter_modes)
        if params[0].zero?
          self.ip = params[1]
        else
          self.ip += 3
        end
      when 7 # lt
        params = decode_params(2, parameter_modes)
        val = params[0] < params[1] ? 1 : 0
        write(val, 2, parameter_modes)
        self.ip += 4
      when 8 # eq
        params = decode_params(2, parameter_modes)
        val = params[0] == params[1] ? 1 : 0
        write(val, 2, parameter_modes)
        self.ip += 4
      when 9 # update relative base
        params = decode_params(1, parameter_modes)
        self.relative_base += params[0]
        self.ip += 2
      when 99
        break
      else
        raise ArgumentError, "Unknown Instruction: #{memory[ip]} at location #{ip}. Memory:\n#{memory.inspect}"
      end
    end
  end

  private

  def decode_instruction(instruction)
    parts = instruction.to_s.chars.reverse
    opcode = (parts.shift + (parts.shift || '0')).reverse.to_i
    [opcode, parts.map(&:to_i)]
  end

  def decode_params(num_params, parameter_modes)
    num_params.times.map { |i|
      val = memory[ip + i + 1] || 0
      case parameter_modes[i]
      when 1 # immediate mode
        val
      when 2 # relative mode
        memory[val + relative_base] || 0
      else # position mode, default
        memory[val] || 0
      end
    }
  end

  def write(value, offset, parameter_modes)
    parameter_mode = parameter_modes[offset] || 0
    case parameter_mode
    when 0
      memory[memory[ip + offset + 1]] = value
    when 2
      memory[memory[ip + offset + 1] + relative_base] = value
    else
      raise ArgumentError, "Unexpected parameter mode #{parameter_mode} for write"
    end
  end
end

if $0 == __FILE__
  memory = ARGF.readlines.map(&:strip).first
  memory = memory.split(',').map(&:to_i)

  computer = Computer.new(memory, [1], [])
  computer.compute!
  puts "Part 1: #{computer.outputs}"

  computer = Computer.new(memory, [2], [])
  computer.compute!
  puts "Part 2: #{computer.outputs}"
end
