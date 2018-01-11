#!/usr/bin/env ruby

class Circuit
  attr_accessor :registry, :gates

  def initialize(gates)
    @registry = {}
    @gates = gates.dup
  end

  def run
    loop do
      break if gates.empty?
      gates.each_with_index do |gate, index|
        if gate.can_evaluate?(registry)
          gates.delete_at(index)
          gate.evaluate(registry)
          break
        end
      end
    end
  end

  class Gate
    attr_accessor :input1, :input2, :op, :output

    def initialize(args)
      @input1 = args['input1']
      @input2 = args['input2']
      @op = args['op']
      @output = args['output']
    end

    def fetch(registry, input)
      input.is_a?(Integer) ? input : registry[input]
    end

    def can_evaluate?(registry)
      required_inputs.all? { |input| fetch(registry, input) }
    end

    def evaluate(registry)
      case op
      when 'AND'
        registry[output] = (fetch(registry, input1) & fetch(registry, input2)) & 0xFFFF
      when 'OR'
        registry[output] = (fetch(registry, input1) | fetch(registry, input2)) & 0xFFFF
      when 'RSHIFT'
        registry[output] = (fetch(registry, input1) >> fetch(registry, input2)) & 0xFFFF
      when 'LSHIFT'
        registry[output] = (fetch(registry, input1) << fetch(registry, input2)) & 0xFFFF
      when 'NOT'
        registry[output] = (~fetch(registry, input2)) & 0xFFFF
      when nil
        registry[output] = fetch(registry, input2)
      else
        raise ArgumentError, "Unknown operator: #{op.inspect}"
      end
    end

    def required_inputs
      case op
      when 'RSHIFT', 'LSHIFT', 'AND', 'OR'
        [ input1, input2 ]
      else
        [ input2 ]
      end
    end

    def self.parse(line)
      re = /(((?<input1>[\w\d]+) )?(?<op>NOT|OR|AND|RSHIFT|LSHIFT) )?(?<input2>[\w\d]+) -> (?<output>\w+)/
      args = re.match(line).named_captures.transform_values { |val| val =~ /\A\d+\z/ ? val.to_i : val }
      new(args)
    end
  end
end

if $0 == __FILE__
  gates = ARGF.readlines.map(&:chomp).map { |line| Circuit::Gate.parse(line) }
  circuit = Circuit.new(gates)
  circuit.run

  puts circuit.registry.inspect
end
