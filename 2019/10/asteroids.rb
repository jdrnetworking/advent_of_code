#!/usr/bin/env ruby

require 'pry-byebug'
require_relative './lib/bios'

class Asteroid
  attr_accessor :x, :y, :id, :visible, :blocked

  def initialize(x,y,id)
    @x = x
    @y = y
    @id = id
    @visible = []
    @blocked = []
  end

  def inspect
    "#<Asteroid #{id} <#{x},#{y}> visible=[#{visible.map(&:id).join(',')}] blocked=[#{blocked.map(&:id).join(',')}]>"
  end

  def short
    "#<Asteroid #{id} <#{x},#{y}>>"
  end

  def visible?(other, all = nil)
    all ||= known
    m, b = slope_intercept(other)
    (all - [self, other]).each do |candidate|
      cm, cb = slope_intercept(candidate)
      if cm == m && cb == b
        if m == Float::INFINITY
          return false if Range.new(*[y, other.y].minmax).cover?(candidate.y)
        else
          return false if Range.new(*[x, other.x].minmax).cover?(candidate.x)
        end
      end
    end
    true
  end

  def known
    visible + blocked
  end

  def vaporize!(victim)
    visible.delete(victim)
  end

  def recalculate_visible
    blocked.each do |other|
      visible << other if visible?(other)
    end
    @blocked -= visible
  end

  def slope_intercept(other)
    if x == other.x
      [Float::INFINITY, nil]
    else
      slope = (other.y - y).to_f / (other.x - x)
      [slope, y - slope * x]
    end
  end
end

class Map
  attr_reader :asteroids

  def initialize(asteroids = [])
    @asteroids = asteroids
  end

  def best
    calculate_best!
    asteroids.max_by { |asteroid| asteroid.visible.count }
  end

  def carnage!(source)
    victims = []
    loop do
      if (victim = source.visible.select { |other| other.x == source.x && other.y < source.y }.max_by(&:y))
        victims << victim
        source.vaporize!(victim)
      end
      source
        .visible
        .select { |other| other.x > source.x }
        .sort_by { |other| m, b = source.slope_intercept(other); m }.each do |victim|

        victims << victim
        source.vaporize!(victim)
      end
      if (victim = source.visible.select { |other| other.x == source.x && other.y > source.y }.min_by(&:y))
        victims << victim
        source.vaporize!(victim)
      end
      source
        .visible
        .select { |other| other.x < source.x }
        .sort_by { |other| m, b = source.slope_intercept(other); m }.each do |victim|

        victims << victim
        source.vaporize!(victim)
      end
      source.recalculate_visible
      break if source.visible.empty?
    end
    victims
  end

  def self.parse(lines)
    id = 'AA'
    asteroids = lines.each_with_object([]).with_index do |(row, c), y|
      row.chars.each_with_index do |marker, x|
        if marker == '#'
          c << Asteroid.new(x, y, id.dup)
          id.succ!
        end
      end
    end
    new(asteroids)
  end

  private

  def calculate_best!
    asteroids.each do |asteroid|
      (asteroids - asteroid.known - [asteroid]).each do |other|
        if asteroid.visible?(other, asteroids)
          asteroid.visible << other
          other.visible << asteroid
        else
          asteroid.blocked << other
          other.blocked << asteroid
        end
      end
    end
  end
end

if $0 == __FILE__
  lines = File.readlines(ARGV[0]).map(&:strip)
  if lines.last =~ /\A\d+,\d+,\d+/
    expected_x, expected_y, expected_1, expected_2 = lines.pop.split(',').map(&:to_i)
  end
  map = Map.parse(lines)
  best = map.best
  BIOS.assert_or_print(expected_1, best.visible.count, label: 'Part 1')
  victims = map.carnage!(best)
  if victims.size >= 200
    special = victims[199]
    BIOS.assert_or_print(expected_2, special.x * 100 + special.y, label: 'Part 2')
  end
end
