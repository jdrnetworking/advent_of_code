#!/usr/bin/env ruby

class Registry
  INSTRUCTION = /\A(?<register>\w+) (?<instruction>inc|dec) (?<operand>[-\d]+) if (?<subject>\w+) (?<condition><=?|>=?|==|!=) (?<term>[-\d]+)\z/.freeze

  attr_reader :registers, :high_water_marks

  def initialize
    @registers = Hash.new(0)
    @high_water_marks = Hash.new(-Float::INFINITY)
  end

  def process(instruction)
    return unless (match = INSTRUCTION.match(instruction))
    if conditional_satisfied(match[:subject], match[:condition], match[:term])
      modify_register(match[:register], match[:instruction], match[:operand])
    end
  end

  def conditional_satisfied(subject, condition, term)
    registers[subject].public_send(condition, Integer(term))
  end

  def modify_register(register, instruction, operand)
    case instruction
    when 'inc'
      registers[register] += Integer(operand)
    when 'dec'
      registers[register] -= Integer(operand)
    end
    high_water_marks[register] = registers[register] if registers[register] > high_water_marks[register]
  end

  def max_register_value
    registers.values.max
  end

  def max_high_water_mark
    high_water_marks.values.max
  end
end

if $0 == __FILE__
  registry = Registry.new
  ARGF.each_line do |line|
    registry.process(line.chomp)
  end
  puts "Max value: #{registry.max_register_value}"
  puts "High water mark: #{registry.max_high_water_mark}"
end
