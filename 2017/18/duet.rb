#!/usr/bin/env ruby

class Duet
  attr_accessor :registers, :outbox, :instructions, :ip, :queue, :deadlocked, :pid

  def initialize(instructions, pid: 0)
    @registers = (?a..?o).each_with_object({}) { |reg,o| o[reg] = 0 }
    @registers['p'] = pid
    @pid = pid
    @instructions = instructions
    @ip = 0
    @queue = []
    @deadlocked = false
    @outbox = nil
  end

  def run
    loop do
      next if deadlocked
      process instructions[ip]
      self.ip += 1
    end
  end

  def step
    return if deadlocked
    process instructions[ip]
    self.ip += 1
    raise "p#{pid}: ip #{ip}: register #{registers.detect { |_,v| v.nil? }.first} is nil" if registers.values.any?(&:nil?)
    self
  end

  def process(instruction)
    case instruction
    when /snd (-?\d+|\w)/
      self.outbox = decode($1)
    when /set (\w) (-?\d+|\w)/
      registers[$1] = decode($2)
    when /add (\w) (-?\d+|\w)/
      registers[$1] += decode($2)
    when /mul (\w) (-?\d+|\w)/
      registers[$1] *= decode($2)
    when /mod (\w) (-?\d+|\w)/
      registers[$1] %= decode($2)
    when /rcv (\w)/
      if value = queue.shift
        registers[$1] = value
      else
        self.deadlocked = true
        self.ip -= 1
      end
    when /jgz (-?\d+|\w) (-?\d+|\w)/
      self.ip += decode($2) - 1 if decode($1) > 0
    end
  end

  def decode(value)
    value =~ /-?\d+/ ? value.to_i : registers[value]
  end

  def enqueue(value)
    queue << value
    self.deadlocked = false
  end

  def dequeue
    value = outbox
    self.outbox = nil
    value
  end

  def to_s
    "ip:#{ip} q:[#{queue.join(' ')}] deadlocked:#{deadlocked} next:#{instructions[ip]} reg:#{registers.map { |k,v| "#{k}:#{v}" }.join(' ')}"
  end

  def inspect
    to_s
  end
end

if $0 == __FILE__
  instructions = ARGF.readlines.map(&:chomp)
  p0 = Duet.new(instructions, pid: 0)
  p1 = Duet.new(instructions, pid: 1)
  p1_sent = 0

  loop do
    p0.step
    if (value = p0.dequeue)
      p1.enqueue(value)
    end
    p1.step
    if (value = p1.dequeue)
      p0.enqueue(value)
      p1_sent += 1
    end
    break if p0.deadlocked && p1.deadlocked
  end
  puts p1_sent
end
