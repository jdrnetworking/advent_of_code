#!/usr/bin/env ruby

class Firewall
  attr_accessor :layers

  def initialize(layer_ranges)
    @layers = []
    layer_ranges.each do |layer_number, range|
      @layers[layer_number] = Layer.new(range)
    end
    @layers.each_with_index do |layer, index|
      @layers[index] = Layer.new if layer.nil?
    end
  end

  def pp(current_layer: nil, extra_info: '')
    puts extra_info unless extra_info.empty?
    layers.size.times.map { |layer| ' %-2d' % layer }.join(' ') + "\n" +
      layers.map(&:range).max.times.map { |cell|
        layers.map.with_index { |layer, index|
          if cell >= layer.range
            index == current_layer && cell.zero? ? '<.>' : '...'
          elsif cell == layer.scanner_position
            index == current_layer && cell.zero? ? '<S>' : '[S]'
          else
            index == current_layer && cell.zero? ? '< >' : '[ ]'
          end
        }.join(' ')
      }.join("\n")
  end

  def inspect
    pp
  end

  def firewalk(delay = 0)
    caught = false
    score = 0
    layers.each { |layer| layer.reset(delay) }
    layers.each_with_index do |layer, depth|
      if layer.caught_at?(0)
        caught = true
        score += depth * layer.range
      end
      layers.each(&:move)
    end
    [caught, score]
  end

  def walk(delay: 0, sleep_delay: 1.0, watch_delay: false)
    caught = false
    system('clear')
    if watch_delay
      layers.each(&:reset)
      puts pp(extra_info: "Delay: #{delay}")
      sleep sleep_delay
      delay.times do
        layers.each(&:move)
        system('clear')
        puts pp(extra_info: "Delay: #{delay}")
        sleep sleep_delay
      end
    else
      layers.each do |layer|
        layer.reset(delay)
      end
      system('clear')
      puts pp(extra_info: "Delay: #{delay}")
      sleep sleep_delay
    end
    layers.each_with_index do |layer, depth|
      system('clear')
      puts pp(current_layer: depth, extra_info: "Delay: #{delay}")
      sleep sleep_delay
      if layer.caught_at?(0)
        system('clear')
        puts pp(current_layer: depth, extra_info: "Delay: #{delay}")
        puts "Caught!"
        sleep sleep_delay
        return false
      end
      layers.each(&:move)
      system('clear')
      puts pp(current_layer: depth, extra_info: "Delay: #{delay}")
      sleep sleep_delay
    end
    true
  end

  def cycle
    @cycle ||= layers.map(&:range).reject(&:zero?).inject { |m,o| m.lcm(o) }
  end

  def self.parse(input)
    input.scan(/(\d+): (\d+)/).map { |config| config.map(&:to_i) }
  end

  class Layer
    attr_accessor :range, :scanner_position, :scanner_direction

    def initialize(range = 0)
      @range = range
      @scanner_position = 0
      @scanner_direction = :down
    end

    def reset(delay = 0)
      @scanner_position = 0
      @scanner_direction = :down

      unless empty?
        delay %= cycle
        delay.times { move }
      end
    end

    def move
      return if empty?

      if scanner_direction == :up
        self.scanner_position -= 1
      else
        self.scanner_position += 1
      end

      if scanner_position == 0
        self.scanner_direction = :down
      elsif scanner_position == range - 1
        self.scanner_direction = :up
      end
    end

    def caught_at?(position)
      return false if empty?

      position == scanner_position
    end

    def empty?
      range.zero?
    end

    def cycle
      return 0 if empty?

      @cycle ||= 2 * range - 2
    end
  end
end

if $0 == __FILE__
  layer_ranges = Firewall.parse(ARGF.read)
  firewall = Firewall.new(layer_ranges)
  _, score = firewall.firewalk
  puts "Score with 0 delay: #{score}"

  cycles = firewall.layers.map(&:cycle)
  min_delay = (0..Float::INFINITY).detect { |delay|
    cycles.each_with_index.none? { |cycle, index|
      next false if cycle.zero? # empty layer
      ((index + delay) % cycle).zero?
    }
  }
  puts "Minimum delay to pass unscathed: #{min_delay}"
end
