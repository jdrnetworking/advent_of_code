#!/usr/bin/env ruby

require 'set'

RULE = /(\w+\s+\w+) bags contain ((?:\d+) (?:\w+\s+\w+) bags?(?:, )?)*/

def parse(input)
  input.split(/\r?\n/).each_with_object(Hash.new { |h,k| h[k] = [] }) { |line, graph|
    color = line[/^(\w+\s+\w+) bags contain/, 1]
    contents = line.scan(/(\d+) (\w+\s+\w+)(?: bags?)/).map { |d| d[0] = d[0].to_i; d }
    graph[color] = contents
  }
end

def invert(graph)
  inverted = Hash.new { |h,k| h[k] = [] }
  graph.each_with_object(inverted) { |(label,contains), inv|
    contains.each do |contain|
      inv[contain.last] << label
    end
  }
end

def containment(color, graph, results = Set.new)
  return results if results.include?(color)
  results << color
  graph[color].reduce(results) { |set, col| containment(col, graph, set) }
end

def count_containment(color, graph, sum = 1)
  return sum if graph[color].empty?
  graph[color].reduce(sum) { |acc, color_count|
    acc + color_count.first * count_containment(color_count.last, graph)
  }
end

if $0 == __FILE__
  input = ARGF.read
  graph = parse(input)
  inverted = invert(graph)
  bags_that_contain_target = containment('shiny gold', inverted) - ['shiny gold']
  puts bags_that_contain_target.size
  puts count_containment('shiny gold', graph, 0)
end
