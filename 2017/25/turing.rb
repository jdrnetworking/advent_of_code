#!/usr/bin/env ruby

class Turing
  attr_accessor :states, :current_state, :current_position, :tape

  def initialize(states, initial_state)
    @states = states.dup
    @current_state = initial_state
    @current_position = 0
    @tape = ['0']
  end

  def step(times = 1)
    times.times do
      cv = current_value
      tape[current_position] = state.write_value(cv)
      send "move_#{state.move_direction(cv)}"
      self.current_state = state.next_state(cv)
    end
    self
  end

  def checksum
    tape.count { |v| v == '1' }
  end

  def to_s
    left = [0, current_position - 3].max
    right = [tape.size, current_position + 3].min
    left, right = right, left if left > right
    (current_position > 3 ? '...' : '') +
      tape[left..right].map.with_index(left) { |value, index|
        current_position == index ? "[#{value}]" : " #{value} "
      }.join +
      (current_position + 4 < tape.size ? '...' : '')
  end

  def inspect
    "#<#{self.class} @current_state=\"#{current_state}\" @current_position=\"#{current_position}\" @tape=\"#{to_s}\">"
  end

  def state
    states[current_state]
  end

  def current_value
    tape[current_position]
  end

  def move_left
    if current_position.zero?
      tape.unshift('0')
    else
      self.current_position -= 1
    end
    self
  end

  def move_right
    if current_position == tape.size - 1
      tape.push('0')
    end
    self.current_position += 1
    self
  end

  class State
    RULE = /In state (?<name>[A-Z]):\n\s+If the current value is 0:\n\s+- Write the value (?<zero_write_value>[01]).\n\s+- Move one slot to the (?<zero_move_direction>\w+).\n\s+- Continue with state (?<zero_next_state>[A-Z]).\n\s+If the current value is 1:\n\s+- Write the value (?<one_write_value>[01]).\n\s+- Move one slot to the (?<one_move_direction>\w+).\n\s+- Continue with state (?<one_next_state>[A-Z])./m.freeze

    attr_accessor :name, :rules

    def initialize(name, rules)
      @name = name
      @rules = rules
    end

    def write_value(current_value)
      rules[current_value][:write_value]
    end

    def move_direction(current_value)
      rules[current_value][:move_direction]
    end

    def next_state(current_value)
      rules[current_value][:next_state]
    end

    def self.parse_states(input)
      input.scan(RULE).each_with_object({}) { |match_data, states|
        state_name = match_data.shift
        rules = {
          '0' => [:write_value, :move_direction, :next_state].zip(match_data.shift(3)).to_h,
          '1' => [:write_value, :move_direction, :next_state].zip(match_data.shift(3)).to_h
        }
        states[state_name] = State.new(state_name, rules)
      }
    end
  end
end

if $0 == __FILE__
  if ARGV.empty?
    puts "Usage: #{File.basename($0)} blueprints.txt"
    exit 1
  end

  blueprints = ARGF.read
  initial_state = blueprints[/Begin in state ([A-Z])/, 1] || 'A'
  steps = (blueprints[/Perform a diagnostic checksum after (\d+) steps/, 1] || 6).to_i
  states = Turing::State.parse_states(blueprints)
  turing = Turing.new(states, initial_state)
  turing.step(steps)
  puts "Checksum after #{steps} steps: #{turing.checksum}"
end
