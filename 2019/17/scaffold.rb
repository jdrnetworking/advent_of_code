#!/usr/bin/env ruby

require 'pry-byebug'
require_relative './lib/computer'

if $0 == __FILE__
  code = ARGF.read.strip.split(',').map(&:to_i)
  input, output = [], []
  computer = Computer.new(code, input, output)
  computer.compute!
  binding.pry
  puts output.size
end
