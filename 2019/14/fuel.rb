#!/usr/bin/env ruby

require_relative './lib/bios'

class Factory
  attr_accessor :requirements

  def initialize(requirements)
    @requirements = requirements
  end

  def ore_required(fuel)
    hopper = requirements.keys.each_with_object({}) { |k,o| o[k] = 0 }
    demand = (requirements.keys + ['ORE']).each_with_object({}) { |k,o| o[k] = 0 }
    demand['FUEL'] = fuel
    fulfill(demand, hopper) until fulfilled?(demand)
    demand['ORE']
  end

  def fulfill(demand, hopper)
    demand.each do |item, qty_needed|
      next if qty_needed.zero?
      next if item == 'ORE'

      if hopper[item] >= qty_needed
        hopper[item] -= qty_needed
        demand[item] = 0
        next
      end
      qty_needed -= hopper[item]
      hopper[item] = 0
      reaction = requirements[item]
      num_reactions_needed = (qty_needed.to_f / reaction[:qty]).ceil
      qty_produced = reaction[:qty] * num_reactions_needed
      hopper[item] += qty_produced - qty_needed
      demand[item] = 0
      reaction[:inputs].each do |input|
        demand[input.last] += input.first * num_reactions_needed
      end
    end
  end

  def fulfilled?(demand)
    demand.reject { |k,v| v.zero? }.keys == ['ORE']
  end

  def fuel_produced(stock)
    fuel = 1
    while ore_required(fuel) <= stock do
      fuel *= 2
    end
    lower, upper = fuel / 2, fuel
    until upper - lower == 1 do
      to_try = (upper + lower) / 2
      result = ore_required(to_try)
      return to_try if result == stock
      if result > stock
        upper = to_try
      else
        lower = to_try
      end
    end
    lower
  end

  def self.parse(lines)
    req = lines.each_with_object({}) { |line, o|
      inputs, output = line.split(' => ')
      qty, item = *qty_re.match(output).captures.tap { |a| a[0] = a[0].to_i }
      o[item] = {
        qty: qty,
        inputs: inputs.split(', ').map { |input|
          qty_re.match(input).captures.tap { |a| a[0] = a[0].to_i }
        }
      }
    }
    new(req)
  end

  def self.qty_re
    /(\d+) (\w+)/
  end
end

if $0 == __FILE__
  lines = ARGF.readlines.map(&:strip)
  unless lines.first.include?(' => ')
    expected_1, expected_2 = lines.shift.split(',').map(&:to_i)
  end

  factory = Factory.parse(lines)
  ore = factory.ore_required(1)
  fuel_produced = factory.fuel_produced(1_000_000_000_000)

  BIOS.assert_or_print(expected_1, ore, label: 'Part 1')
  BIOS.assert_or_print(expected_2, fuel_produced, label: 'Part 2')
end
