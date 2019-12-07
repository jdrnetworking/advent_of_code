#!/usr/bin/env ruby

def fuel_for_module(mass, initial=0)
  return initial if mass.to_s.strip.empty?
  fuel = [0, (mass.to_f / 3.0).floor - 2].max
  fuel == 0 ? initial : fuel_for_module(fuel, initial+fuel)
end

total = ARGF.readlines.inject(0) do |total,mod|
  total + fuel_for_module(mod)
end
puts total
