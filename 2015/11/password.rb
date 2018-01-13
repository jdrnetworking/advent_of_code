#!/usr/bin/env ruby

class Password
  attr_accessor :password, :validations

  def initialize(password)
    @password = password
    @validations = []
  end

  def next!
    loop do
      self.password = password.succ
      break if valid?
    end
    password
  end

  def valid?
    validations.all? { |valid| valid[password] }
  end
end

if $0 == __FILE__
  if ARGV.empty?
    puts "Usage: #{File.basename $0} password"
    exit 1
  end

  password = Password.new(ARGV.shift)
  password.validations = [
    ->(pw) { pw.match? /abc|bcd|cde|def|efg|fgh|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz/ },
    ->(pw) { !pw.match? /[iol]/ },
    ->(pw) { pw.match? /(.)\1.*((?!\1).)\2/ }
  ]
  puts "Password is #{'not ' unless password.valid?}valid"
  puts "Next password is #{password.next!}"
  puts "Next password is #{password.next!}"
end

