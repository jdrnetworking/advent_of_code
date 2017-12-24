#!/usr/bin/env ruby

class BridgeBuilder
  attr_accessor :components
  def initialize(components)
    @components = components
  end

  def possible_bridges(from_port = 0, available = components)
    (available.select { |component|
      component.start_with?(from_port)
    }.map { |component|
      [component] + possible_bridges(component.last, available - [component])
    } + available.select { |component|
      component.end_with?(from_port)
    }.map { |component|
      [component] + possible_bridges(component.first, available - [component])
    }).uniq
  end

  def bridges
    possible_bridges.map { |chain|
      Array(denestify([], *chain))
    }.inject(&:+)
  end

  def denestify(parents, first, *children)
    if children.empty?
      Bridge.new(parents + [first])
    else
      [Bridge.new(parents + [first])] +
      children.flat_map { |child|
        denestify(parents + [first], *child)
      }
    end
  end
end

class Bridge
  attr_accessor :components, :initial_port

  def initialize(components, initial_port: 0)
    @components = components
    @initial_port = initial_port
  end

  def length
    components.length
  end

  def strength
    components.map(&:strength).sum
  end
end

class Component
  attr_accessor :ports

  def initialize(ports)
    @ports = ports
  end

  def first
    ports.first
  end

  def last
    ports.last
  end

  def start_with?(count)
    ports.first == count
  end

  def end_with?(count)
    ports.last == count
  end

  def compatible?(pin_count)
    ports.include?(pin_count)
  end

  def strength
    ports.sum
  end

  def to_s
    ports.join('/')
  end

  def inspect
    to_s
  end

  def self.parse(port_string)
    new(port_string.split(?/).map(&:to_i))
  end
end

if $0 == __FILE__
  if ARGV.empty?
    puts "Usage: #{File.basename($0)} input.txt"
    exit 1
  end

  components = ARGF.readlines.map(&:chomp).map { |str| Component.parse(str) }
  builder = BridgeBuilder.new(components)
  bridges = builder.bridges
  puts "Max strength: #{bridges.map(&:strength).max}"
  sorted_bridges = bridges.sort_by { |bridge| [bridge.length, bridge.strength] }
  puts "Strongest, longest bridge: #{sorted_bridges.last.strength}"
end
