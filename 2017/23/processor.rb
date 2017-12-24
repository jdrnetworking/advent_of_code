#!/usr/bin/env ruby

require 'prime'
require 'forwardable'

class Processor
  extend Forwardable

  attr_accessor :instructions, :registers, :ip, :mul_count
  def_delegators :@registers, :[]

  def initialize(instructions, registers)
    @registers = registers.dup
    @instructions = instructions.dup
    @ip = 0
    @mul_count = 0
  end

  def run
    loop do
      break if instructions[ip].nil?
      process instructions[ip]
      self.ip += 1
    end
  end

  def step(steps = 1)
    steps.times do
      process instructions[ip]
      self.ip += 1
      raise "ip #{ip}: register #{registers.detect { |_,v| v.nil? }.first} is nil" if registers.values.any?(&:nil?)
    end
    self
  end

  def process(instruction)
    case instruction
    when /set (\w) (-?\d+|\w)/
      registers[$1] = decode($2)
    when /sub (\w) (-?\d+|\w)/
      registers[$1] -= decode($2)
    when /mul (\w) (-?\d+|\w)/
      self.mul_count += 1
      registers[$1] *= decode($2)
    when /jnz (-?\d+|\w) (-?\d+|\w)/
      self.ip += decode($2) - 1 if decode($1) != 0
    end
  end

  def decode(value)
    value =~ /-?\d+/ ? value.to_i : registers[value]
  end

  def to_s
    "ip:#{ip} next:#{instructions[ip]} reg:#{registers.map { |k,v| "#{k}:#{v}" }.join(' ')}"
  end

  def inspect
    to_s
  end
end

if $0 == __FILE__
  instructions = ARGF.readlines.map(&:chomp)
  registers = (?a..?h).each_with_object({}) { |reg,o| o[reg] = 0 }
  cop = Processor.new(instructions, registers)
  cop.run
  puts "#{cop.mul_count} mul instructions processed"

  registers['a'] = 1
  cop = Processor.new(instructions, registers)
  cop.step(7)
  from = cop['b']
  to = cop['c']
  step = instructions[-2][/sub b (-?\d+|\w)/, 1].to_i * -1
  h = (from..to).step(step).count { |x| !x.prime? }
  puts "Optimzed program h: #{h}"
end
