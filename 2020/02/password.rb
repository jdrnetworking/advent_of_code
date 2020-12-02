#!/usr/bin/env ruby

POLICY = /(?<min>\d+)-(?<max>\d+)\s*(?<char>\w+):\s*(?<password>.*)/

if $0 == __FILE__
  passwords = ARGF.each_line.map { |line| POLICY.match(line) }
  puts passwords.count { |p|
    (p[:min].to_i..p[:max].to_i).cover?(p[:password].chars.group_by(&:itself).transform_values(&:size)[p[:char]])
  }
  puts passwords.count { |p|
    p[:password].chars.values_at(p[:min].to_i - 1, p[:max].to_i - 1).map { |c| c == p[:char] }.inject(:^)
  }
end
