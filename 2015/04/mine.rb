#!/usr/bin/env ruby

require 'digest/md5'

if ARGV.empty?
  puts "Usage: #{File.basename $0} secret [zeroes=5]"
  exit 1
end

secret = ARGV.shift
prefix_length = ARGV.shift.to_i.nonzero? || 5

key = (1..Float::INFINITY).detect { |i| Digest::MD5.hexdigest("#{secret}#{i}").start_with?('0'*prefix_length) }
puts "#{key}: #{Digest::MD5.hexdigest("#{secret}#{key}")}"
