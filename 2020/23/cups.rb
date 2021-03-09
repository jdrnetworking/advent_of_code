#!/usr/bin/env ruby

def delegate_missing_to(target, allow_nil: nil)
  target = target.to_s

  module_eval <<-RUBY, __FILE__, __LINE__ + 1
    def respond_to_missing?(name, include_private = false)
      # It may look like an oversight, but we deliberately do not pass
      # +include_private+, because they do not get delegated.

      return false if name == :marshal_dump || name == :_dump
      #{target}.respond_to?(name) || super
    end

    def method_missing(method, *args, &block)
      if #{target}.respond_to?(method)
        #{target}.public_send(method, *args, &block)
      else
        begin
          super
        rescue NoMethodError
          if #{target}.nil?
            if #{allow_nil == true}
              nil
            else
              raise DelegationError, "\#{method} delegated to #{target}, but #{target} is nil"
            end
          else
            raise
          end
        end
      end
    end
    ruby2_keywords(:method_missing) if respond_to?(:ruby2_keywords, true)
  RUBY
end

class CircularArray
  attr_reader :items, :current

  delegate_missing_to :items

  def initialize(items, current: 0)
    @items = items.dup
    @current = current
  end

  def [](*args)
    if args.size == 1 && Integer === args[0]
      items[args[0] % items.size]
    elsif args.size == 1 && Range === args[0]
      self[args[0].first, args[0].size]
    elsif args.size == 2
      start, length = args
      length.times.map { |i| self[i + start] }
    end
  end

  def rotate(n = 1)
    @current = (current + n) % size
    self
  end

  def extract(count, offset: 0)
    if current + offset + count <= size
      items.slice!(current + offset, count)
    else
      rem = current + offset + count - size
      (items.slice!(current + offset, count - rem) + items.slice!(0, rem)).tap do
        @current -= rem
      end
    end
  end

  def insert_after(value, elements)
    destination = items.find_index(value) + 1
    items.insert(destination, *elements)
    @current += elements.size if destination <= current
    self
  end

  def items_from_current
    items[current..-1] + items[0...current]
  end

  def to_s
    size.times.map { |i| i == current ? "(#{items[i]})" : items[i].to_s }.join(' ')
  end
end

def parse(input)
  input.chomp.chars.map(&:to_i)
end

def score(cups)
  cups[cups.find_index(1) + 1, cups.size - 1].join
end

def play(cups, rounds: 100)
  rounds.times do
    cups = play_round(cups)
  end
  cups
end

def play_round(cups)
  extracted = cups.extract(3, offset: 1)
  destination = cups.select { |v| v < cups[cups.current] }.max || cups.max
  cups.insert_after(destination, extracted)
  cups.rotate
end

if $0 == __FILE__
  input = parse(File.read(ARGV[0]))
  cups = CircularArray.new(input.dup)
  rounds = ARGV.size > 1 ? ARGV[1].to_i : 100
  #cups = play(cups, rounds: rounds)
  #puts score(cups)
  size = 1000000
  cups = CircularArray.new(input.dup + ((input.size + 1)..size).to_a)
end
