#!/usr/bin/env ruby

class Graph
  attr_accessor :routes

  def initialize(routes)
    @routes = routes.dup
  end

  def cities
    routes.keys.flatten.uniq.sort
  end

  def shortest_route
    cities.permutation.min_by { |route| route_length(route) }
  end

  def longest_route
    cities.permutation.max_by { |route| route_length(route) }
  end

  def route_length(route)
    route.each_cons(2).map { |city_pair| routes[city_pair.sort] }.sum
  end

  def self.parse(input)
    new(input.each_with_object({}) { |line, _routes| _routes.merge!(parse_route(line)) })
  end

  def self.parse_route(string)
    md = string.match(/(?<city1>\w+) to (?<city2>\w+) = (?<dist>\d+)/).captures
    { md[0,2].sort => md[2].to_i }
  end
end

if $0 == __FILE__
  graph = Graph.parse(ARGF.readlines.map(&:chomp))
  shortest_route = graph.shortest_route
  puts "Shortest: #{shortest_route.join(' -> ')}: #{graph.route_length(shortest_route)}"
  longest_route = graph.longest_route
  puts "Longest: #{longest_route.join(' -> ')}: #{graph.route_length(longest_route)}"
end
