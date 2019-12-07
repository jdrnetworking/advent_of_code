#!/usr/bin/env ruby

class Thing
  attr_reader :name, :satellites
  attr_accessor :parent

  def initialize(name:, satellites: [], parent: nil)
    @name = name
    @satellites = satellites.dup
    @parent = parent
  end

  def total_orbits(depth: 0)
    depth + satellites.map { |s| s.total_orbits(depth: depth + 1) }.sum
  end

  def ancestors
    return [] unless parent
    parent.ancestors + [parent]
  end

  def inspect
    "#<Thing #{name} parent=#{parent&.name} satellites=[#{satellites.map(&:name).join(',')}]>"
  end
end

if $0 == __FILE__
  things = {}
  ARGF.readlines.map(&:strip).each do |input|
    thing, satellite = input.split(')')
    things[thing] ||= Thing.new(name: thing)
    things[satellite] ||= Thing.new(name: satellite)
    things[satellite].parent = things[thing]
    things[thing].satellites << things[satellite]
  end

  # Part 1
  root = things.values.detect { |thing| thing.parent.nil? }
  puts root.total_orbits

  # Part 2
  if things['YOU'] && things['SAN']
    puts (things['YOU'].ancestors - things['SAN'].ancestors).size +
      (things['SAN'].ancestors - things['YOU'].ancestors).size
  end
end
