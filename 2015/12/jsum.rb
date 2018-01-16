#!/usr/bin/env ruby

require 'json'

def jsum(obj)
  case obj
  when Array
    obj.map { |v| jsum(v) }.sum
  when Integer
    obj
  when Hash
    obj.values.map { |v| jsum(v) }.sum
  else
    0
  end
end

def jsum_filtered(obj)
  case obj
  when Array
    obj.map { |v| jsum_filtered(v) }.sum
  when Integer
    obj
  when Hash
    if obj.values.include?('red')
      0
    else
      obj.values.map { |v| jsum_filtered(v) }.sum
    end
  else
    0
  end
end

if $0 == __FILE__
  input = ARGF.readlines.map(&:chomp)
  input.each do |line|
    puts "#{line[0,30]}: #{jsum(JSON.parse(line))}"
  end
  input.each do |line|
    puts "#{line[0,30]}: #{jsum_filtered(JSON.parse(line))}"
  end
end
