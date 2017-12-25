#!/usr/bin/env ruby

module Paper
  module_function

  def areas(dimensions)
    [
      dimensions[0] * dimensions[1],
      dimensions[0] * dimensions[2],
      dimensions[1] * dimensions[2]
    ]
  end

  def parse_dimensions(string)
    string.split('x').map(&:to_i)
  end

  def paper_needed(string)
    dimensions = parse_dimensions(string)
    side_areas = areas(dimensions)
    extra = side_areas.min
    side_areas.inject(&:+) * 2 + extra
  end

  def ribbon_needed(string)
    dimensions = parse_dimensions(string)
    dimensions.sort.take(2).inject(&:+) * 2 + dimensions.inject(&:*)
  end
end

if $0 == __FILE__
  packages = ARGF.readlines.map(&:chomp)
  total_paper_needed = packages.map { |package| Paper.paper_needed(package) }.sum
  puts "Total paper for #{packages.size} packages: #{total_paper_needed}"
  total_ribbon_needed = packages.map { |package| Paper.ribbon_needed(package) }.sum
  puts "Total ribbon for #{packages.size} packages: #{total_ribbon_needed}"
end
