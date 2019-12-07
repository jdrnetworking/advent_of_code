#!/usr/bin/env ruby

def fuel_for_module(mass)
  return 0 if mass.to_s.strip.empty?
  [0, (mass.to_f / 3.0).floor - 2].max
end

total = ARGF.readlines.inject(0) do |m,v|
  m + fuel_for_module(v)
end
puts total
