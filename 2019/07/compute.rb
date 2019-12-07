#!/usr/bin/env ruby

require 'pry-byebug'

class Computer
  attr_reader :memory, :inputs, :outputs, :name

  def initialize(memory, inputs, outputs, name: nil)
    @memory = memory.dup
    @inputs = inputs
    @outputs = outputs
    @name = name || rand(1000)
  end

  def compute!
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
        input = inputs.pop
        memory[memory[ip + 1]] = input
        ip += 2
      when 4
        val = memory[ip + 1]
        param = parameter_modes[0] == 1 ? val : memory[val]
        outputs << param
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
  end

  private

  def decode_instruction(instruction)
    parts = instruction.to_s.chars.reverse
    opcode = (parts.shift + (parts.shift || '0')).reverse.to_i
    [opcode, parts.map(&:to_i)]
  end
end

if $0 == __FILE__
  mode, available_phase_settings, memory, expected = ARGF.readlines.map(&:strip)
  available_phase_settings = available_phase_settings.chars.map(&:to_i)
  memory = memory.split(',').map(&:to_i)

  case mode
  when 'linear'
    max = 0
    available_phase_settings.permutation.each do |phase_settings|
      thrust_setting = phase_settings.inject(0) { |previous_output,phase_setting|
        computer = Computer.new(memory, Queue.new << phase_setting << previous_output, Queue.new)
        computer.compute!
        computer.outputs.pop
      }
      if thrust_setting > max
        max = thrust_setting
      end
    end
  when 'feedback'
    max = 0
    available_phase_settings.permutation.each do |phase_settings|
      pipes = phase_settings.map { |phase_setting| Queue.new << phase_setting }
      pipes[0] << 0
      computers = 5.times.map { |i|
        Thread.new do
          Computer.new(memory, pipes[i], pipes[(i + 1) % 5], name: i).compute!
        end
      }
      computers.each(&:join)
      thrust_setting = pipes[0].pop
      if thrust_setting > max
        max = thrust_setting
      end
    end
  else
    raise ArgumentError, "Unexpected mode '#{mode}'"
  end

  if expected
    puts "Expected #{expected}, got #{max} #{expected.to_i == max ? '✅' : 'ｘ'}"
  else
    puts max
  end
end
