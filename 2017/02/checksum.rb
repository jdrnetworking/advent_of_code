#!/usr/bin/env ruby

class Checksum
  attr_reader :input

  def initialize(input)
    @input = input.to_s
  end

  def checksum
    matrix.sum { |row| row_checksum(row) }
  end

  private

  def matrix
    input.split(/[\r\n]+/).map { |line| line.split.map { |cell| Integer(cell) } }
  end

  def row_checksum(row)
    row.max - row.min
  end
end

class Checksum2 < Checksum
  private

  def row_checksum(row)
    row.each do |cell|
      (row - [cell]).each do |other|
        return other / cell if (other % cell).zero?
      end
    end
  end
end

if $0 == __FILE__
  input = STDIN.read.chomp
  puts
  puts Checksum2.new(input).checksum
end
