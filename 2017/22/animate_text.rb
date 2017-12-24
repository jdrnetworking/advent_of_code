#!/usr/bin/env ruby

require_relative 'virus'

if ARGV.size < 3
  puts "Usage: #{$0} skip_iterations total_iterations input_file"
  exit 1
end

initial_iterations = ARGV.shift.to_i
iterations = ARGV.shift.to_i
grid = ARGF.readlines.map { |line| line.chomp.chars }
cluster = Cluster.new(grid)
carrier = Carrier.new(cluster, Carrier.rules_2)
initial_iterations.times { carrier.burst }
system('clear'); puts cluster.print
iterations.times { carrier.burst; sleep 0.05; system('clear'); puts cluster.print }
