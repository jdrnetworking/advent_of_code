#!/usr/bin/env ruby -w

class InverseCaptcha
  attr_reader :input

  def initialize(input)
    self.input = input
  end

  def input=(new_input)
    @digits = nil
    @input = new_input.to_s
  end

  def answer
    sum = 0
    digits.each_with_index do |digit, index|
      sum += digit if matches?(digit, digits, index)
    end
    sum
  end

  private

  def matches?(digit, digits, index)
    digits[match_index(digits, index)] == digit
  end

  def match_index(digits, index)
    (index + 1) % digits.length
  end

  def digits
    @digits ||= input.chars.map { |character|
      begin
        Integer(character)
      rescue ArgumentError, TypeError
        0
      end
    }
  end
end

class InverseCaptcha2 < InverseCaptcha
  private

  def match_index(digits, index)
    (index + digits.length / 2) % digits.length
  end
end

if $0 == __FILE__
  puts InverseCaptcha2.new(ARGV.first).answer
end
