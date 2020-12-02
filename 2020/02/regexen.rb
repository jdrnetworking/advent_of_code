#!/usr/bin/env ruby

POLICY = /(?<min>\d+)-(?<max>\d+)\s*(?<char>\w+):\s*(?<password>.*)/

if $0 == __FILE__
  passwords = ARGF.each_line.map(&:chomp)
  puts passwords.count { |line|
    p = POLICY.match(line)
    policy = Regexp.new("^[^#{p[:char]}]*(#{p[:char]}[^#{p[:char]}]*){#{p[:min]},#{p[:max]}}$")
    policy.match?(p[:password])
  }
  puts passwords.count { |line|
    p = POLICY.match(line)
    policy = Regexp.new(
      "^
      .{#{p[:min].to_i - 1}}
      (
        #{p[:char]}.{#{p[:max].to_i - p[:min].to_i - 1}}[^#{p[:char]}]
        |
        [^#{p[:char]}].{#{p[:max].to_i - p[:min].to_i - 1}}#{p[:char]}
      )
      ",
      Regexp::EXTENDED
    )
    policy.match?(p[:password])
  }
end
