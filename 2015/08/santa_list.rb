#!/usr/bin/env ruby

def code_length_of(string)
  string.length
end

def string_length_of(string)
  string.gsub(/\A"/, '').gsub(/"\z/, '').scan(/\\"|\\x\X\X|\\\\|./).size
end

def encode_string(string)
  '"' + string.gsub('\\', '\\\\\\\\').gsub('"', '\\\\"') + '"'
end

if $0 == __FILE__
  strings = ARGF.readlines.map(&:chomp)
  puts strings.inject(0) { |sum, string| sum + code_length_of(string) - string_length_of(string) }
  puts strings.inject(0) { |sum, string| sum + code_length_of(encode_string(string)) - code_length_of(string) }
end
