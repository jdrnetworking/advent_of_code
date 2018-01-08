#!/usr/bin/env ruby

class Lights
  attr_accessor :width, :height, :grid

  def initialize(width: 1000, height: 1000)
    @width = width
    @height = height
    @grid = Array.new(@height) { Array.new(@width, 0) }
  end

  def count
    grid.map { |row| row.sum }.sum
  end

  def run(instruction)
    (instruction.row_start..instruction.row_end).each do |row|
      (instruction.col_start..instruction.col_end).each do |col|
        case instruction.instruction
        when 'turn on'
          grid[row][col] = 1
        when 'turn off'
          grid[row][col] = 0
        when 'toggle'
          grid[row][col] = (grid[row][col] + 1) % 2
        when 'increase'
          grid[row][col] += 1
        when 'decrease'
          grid[row][col] = [grid[row][col] - 1, 0].max
        when 'really_increase'
          grid[row][col] += 2
        end
      end
    end
  end

  class Instruction
    attr_accessor :instruction, :row_start, :col_start, :row_end, :col_end

    def initialize(instruction, row_start, col_start, row_end, col_end)
      @instruction = instruction
      @row_start = row_start.to_i
      @col_start = col_start.to_i
      @row_end = row_end.to_i
      @col_end = col_end.to_i
    end

    def self.parse(line)
      if (md = matcher.match(line))
        new(*md.captures)
      end
    end

    def self.matcher
      /(?<instruction>turn on|turn off|toggle) (?<row_start>\d+),(?<col_start>\d+) through (?<row_end>\d+),(?<col_end>\d+)/.freeze
    end
  end
end

if $0 == __FILE__
  rules = ARGF.readlines.map { |line|
    Lights::Instruction.parse(line.chomp)
  }
  lights = Lights.new
  rules.each do |rule|
    lights.run(rule)
  end
  puts "After #{rules.size} rules, #{lights.count} are left on"

  rules.each do |rule|
    rule.instruction = case rule.instruction
                       when 'turn on' then 'increase'
                       when 'turn off' then 'decrease'
                       when 'toggle' then 'really_increase'
                       end
  end
  lights = Lights.new
  rules.each do |rule|
    lights.run(rule)
  end
  puts "After #{rules.size} rules interpreted as Ancient Nordic Elvish, total brightness is #{lights.count}"
end
