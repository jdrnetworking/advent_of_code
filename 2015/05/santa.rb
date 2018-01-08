#!/usr/bin/env ruby

class Santa
  attr_accessor :rules

  def initialize(rules)
    @rules = rules.dup
  end

  def nice?(string)
    rules.all? { |rule| rule[string] }
  end
end

if $0 == __FILE__
  lines = ARGF.readlines.map(&:chomp)

  rules = [
    ->(string) { string.scan(/[aeiou]/).to_a.length >= 3 },
    ->(string) { string.match?(/([a-z])\1/) },
    ->(string) { %w(ab cd pq xy).none? { |bad| string.include?(bad) } }
  ]
  santa = Santa.new(rules)

  nice_count = 0
  lines.each do |string|
    puts "#{string}: #{santa.nice?(string) ? (nice_count += 1; 'Nice') : 'Naughty'}"
  end
  puts nice_count

  rules = [
    ->(string) { string.match?(/([a-z]{2}).*\1/) },
    ->(string) { string.match?(/([a-z]).\1/) }
  ]
  santa = Santa.new(rules)

  nice_count = 0
  lines.each do |string|
    puts "#{string}: #{santa.nice?(string) ? (nice_count += 1; 'Nice') : 'Naughty'}"
  end
  puts nice_count
end
