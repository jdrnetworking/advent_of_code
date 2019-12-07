#!/usr/bin/env ruby

require 'minitest'
require 'set'

class Point
  attr_accessor :x, :y

  def initialize(x = 0, y = 0)
    @x, @y = x, y
  end

  def origin?
    x.zero? && y.zero?
  end

  def manhattan_magnitude
    x.abs + y.abs
  end

  def distance_to(other)
    (x - other.x).abs + (y - other.y).abs
  end

  def inspect
    "#<Point [#{x},#{y}]>"
  end

  def ==(other)
    x == other.x && y == other.y
  end
end

class Segment
  attr_accessor :point1, :point2

  def self.from_coords(x1, y1, x2, y2)
    new(Point.new(x1, y1), Point.new(x2, y2))
  end

  def initialize(point1, point2)
    @point1, @point2 = point1, point2
  end

  def length
    point1.distance_to(point2)
  end

  def contains?(point)
    if horizontal?
      min_x, max_x = [point1.x, point2.x].minmax
      point.y == point1.y && point.x >= min_x && point.x <= max_x
    elsif vertical?
      min_y, max_y = [point1.y, point2.y].minmax
      point.x == point1.x && point.y >= min_y && point.y <= max_y
    else
      raise ArgumentError, "#contains? is only defined for horizontal and vertical segments"
    end
  end

  def vertical?
    point1.x == point2.x
  end

  def horizontal?
    point1.y == point2.y
  end

  def intersects_with?(other)
    !intersections_with(other).empty?
  end

  def intersections_with(other)
    if horizontal? && other.horizontal?
      return [] unless point1.y == other.point1.y && point2.x >= other.point1.x && point1.x <= other.point2.x
      start = [[point1.x, point2.x].min, [other.point1.x, other.point2.x].min].max
      stop = [[point1.x, point2.x].max, [other.point1.x, other.point2.x].max].min
      (start..stop).map { |x| Point.new(x, point1.y) }
    elsif vertical? & other.vertical?
      return [] unless point1.x == other.point1.x && point2.y >= other.point1.y && point1.y <= other.point2.y
      start = [[point1.y, point2.y].min, [other.point1.y, other.point2.y].min].max
      stop = [[point1.y, point2.y].max, [other.point1.y, other.point2.y].max].min
      (start..stop).map { |y| Point.new(point1.x, y) }
    else
      h, v = horizontal? ? [self, other] : [other, self]
      min_x, max_x = [h.point1.x, h.point2.x].minmax
      min_y, max_y = [v.point1.y, v.point2.y].minmax
      return [] unless h.point1.y >= min_y && h.point1.y <= max_y && v.point1.x >= min_x && v.point1.x <= max_x
      [Point.new(v.point1.x, h.point1.y)]
    end
  end

  def inspect
    "#<Segment #{point1.inspect}-#{point2.inspect}>"
  end

  class Test < Minitest::Test
    def self.autorun_tests
      require 'minitest/autorun'
    end

    def test_horizontal_intersection
      segment1 = Segment.from_coords(-1, 0, 1, 0)
      segment2 = Segment.from_coords(-1, -1, 1, -1)
      segment3 = Segment.from_coords(-3, 0, -2, 0)
      segment4 = Segment.from_coords(-2, 0, -1, 0)
      segment5 = Segment.from_coords(-1, 1, 1, 1)
      segment6 = Segment.from_coords(1, 0, 2, 0)
      segment7 = Segment.from_coords(2, 0, 3, 0)
      segment8 = Segment.from_coords(0, 0, 1, 0)

      assert segment1.horizontal?
      assert segment2.horizontal?
      assert segment3.horizontal?
      assert segment4.horizontal?
      assert segment5.horizontal?
      assert segment6.horizontal?
      assert segment7.horizontal?
      assert segment8.horizontal?

      assert !segment1.intersects_with?(segment2)
      assert !segment1.intersects_with?(segment3)
      assert segment1.intersects_with?(segment4)
      assert !segment1.intersects_with?(segment5)
      assert segment1.intersects_with?(segment6)
      assert !segment1.intersects_with?(segment7)
      assert segment1.intersects_with?(segment8)
    end

    def test_vertical_intersection
      segment1 = Segment.from_coords(0, -1, 0, 1)
      segment2 = Segment.from_coords(-1, -1, -1, 1)
      segment3 = Segment.from_coords(0, -3, 0, -2)
      segment4 = Segment.from_coords(0, -2, 0, -1)
      segment5 = Segment.from_coords(1, -1, 1, 1)
      segment6 = Segment.from_coords(0, 1, 0, 2)
      segment7 = Segment.from_coords(0, 2, 0, 3)
      segment8 = Segment.from_coords(0, 0, 0, 1)

      assert segment1.vertical?
      assert segment2.vertical?
      assert segment3.vertical?
      assert segment4.vertical?
      assert segment5.vertical?
      assert segment6.vertical?
      assert segment7.vertical?
      assert segment8.vertical?

      assert !segment1.intersects_with?(segment2)
      assert !segment1.intersects_with?(segment3)
      assert segment1.intersects_with?(segment4)
      assert !segment1.intersects_with?(segment5)
      assert segment1.intersects_with?(segment6)
      assert !segment1.intersects_with?(segment7)
      assert segment1.intersects_with?(segment8)
    end

    def test_intersection
      h1 = Segment.from_coords(-1, -2, 1, -2)
      h2 = Segment.from_coords(-1, -1, 1, -1)
      h3 = Segment.from_coords(-1, 0, 1, 0)
      h4 = Segment.from_coords(-1, 1, 1, 1)
      h5 = Segment.from_coords(-1, 2, 1, 2)

      v1 = Segment.from_coords(-2, -1, -2, 1)
      v2 = Segment.from_coords(-1, -1, -1, 1)
      v3 = Segment.from_coords(0, -1, 0, 1)
      v4 = Segment.from_coords(1, -1, 1, 1)
      v5 = Segment.from_coords(2, -1, 2, 1)

      [h1, h2, h3, h4, h5].each { |h| assert h.horizontal? }
      [v1, v2, v3, v4, v5].each { |v| assert v.vertical? }

      [
        [h1, v1],
        [h1, v2],
        [h1, v3],
        [h1, v4],
        [h1, v5],
        [h2, v1],
        [h2, v5],
        [h3, v1],
        [h3, v5],
        [h4, v1],
        [h4, v5],
        [h5, v1],
        [h5, v2],
        [h5, v3],
        [h5, v4],
        [h5, v5]
      ].each do |h, v|
        assert !h.intersects_with?(v)
      end

      [
        [h2, v2],
        [h2, v3],
        [h2, v4],
        [h3, v2],
        [h3, v3],
        [h3, v4],
        [h4, v2],
        [h4, v3],
        [h4, v4]
      ].each do |h, v|
        assert h.intersects_with?(v)
      end
    end

    def test_horizontal_intersections
      control = Segment.from_coords(-1, 0, 1, 0)

      segment1 = Segment.from_coords(-4, 0, -2, 0)
      assert_equal [], control.intersections_with(segment1)

      segment2 = Segment.from_coords(-3, 0, -1, 0)
      assert_equal [Point.new(-1, 0)], control.intersections_with(segment2)

      segment3 = Segment.from_coords(-2, 0, 0, 0)
      assert_equal [Point.new(-1, 0), Point.new(0, 0)], control.intersections_with(segment3)

      segment4 = Segment.from_coords(-1, 0, 1, 0)
      assert_equal [Point.new(-1, 0), Point.new(0, 0), Point.new(1, 0)], control.intersections_with(segment4)

      segment5 = Segment.from_coords(0, 0, 2, 0)
      assert_equal [Point.new(0, 0), Point.new(1, 0)], control.intersections_with(segment5)

      segment6 = Segment.from_coords(1, 0, 3, 0)
      assert_equal [Point.new(1, 0)], control.intersections_with(segment6)

      segment7 = Segment.from_coords(2, 0, 4, 0)
      assert_equal [], control.intersections_with(segment7)
    end

    def test_vertical_intersections
      control = Segment.from_coords(0, -1, 0, 1)

      segment1 = Segment.from_coords(0, -4, 0, -2)
      assert_equal [], control.intersections_with(segment1)

      segment2 = Segment.from_coords(0, -3, 0, -1)
      assert_equal [Point.new(0, -1)], control.intersections_with(segment2)

      segment3 = Segment.from_coords(0, -2, 0, 0)
      assert_equal [Point.new(0, -1), Point.new(0, 0)], control.intersections_with(segment3)

      segment4 = Segment.from_coords(0, -1, 0, 1)
      assert_equal [Point.new(0, -1), Point.new(0, 0), Point.new(0, 1)], control.intersections_with(segment4)

      segment5 = Segment.from_coords(0, 0, 0, 2)
      assert_equal [Point.new(0, 0), Point.new(0, 1)], control.intersections_with(segment5)

      segment6 = Segment.from_coords(0, 1, 0, 3)
      assert_equal [Point.new(0, 1)], control.intersections_with(segment6)

      segment7 = Segment.from_coords(0, 2, 0, 4)
      assert_equal [], control.intersections_with(segment7)
    end

    def test_intersections
      h1 = Segment.from_coords(-1, -2, 1, -2)
      h2 = Segment.from_coords(-1, -1, 1, -1)
      h3 = Segment.from_coords(-1, 0, 1, 0)
      h4 = Segment.from_coords(-1, 1, 1, 1)
      h5 = Segment.from_coords(-1, 2, 1, 2)

      v1 = Segment.from_coords(-2, -1, -2, 1)
      v2 = Segment.from_coords(-1, -1, -1, 1)
      v3 = Segment.from_coords(0, -1, 0, 1)
      v4 = Segment.from_coords(1, -1, 1, 1)
      v5 = Segment.from_coords(2, -1, 2, 1)

      assert_equal [Point.new(-1, -1)], h2.intersections_with(v2)
      assert_equal [Point.new(0, -1)], h2.intersections_with(v3)
      assert_equal [Point.new(1, -1)], h2.intersections_with(v4)
      assert_equal [Point.new(-1, 0)], h3.intersections_with(v2)
      assert_equal [Point.new(0, 0)], h3.intersections_with(v3)
      assert_equal [Point.new(1, 0)], h3.intersections_with(v4)
      assert_equal [Point.new(-1, 1)], h4.intersections_with(v2)
      assert_equal [Point.new(0, 1)], h4.intersections_with(v3)
      assert_equal [Point.new(1, 1)], h4.intersections_with(v4)
    end
  end
end

class Wire
  attr_reader :segments

  def initialize(segments)
    @segments = segments
  end

  def wire_distance_to(point)
    running_distance = 0
    segments.each do |segment|
      if segment.contains?(point)
        running_distance += segment.point1.distance_to(point)
        break
      else
        running_distance += segment.length
      end
    end
    running_distance
  end

  def self.parse(path)
    current = Point.new
    new(path.split(',').map { |segment_def| parse_segment(segment_def, current) })
  end

  def self.parse_segment(segment_def, current)
    direction, length  = /([UDLR])(\d+)/.match(segment_def).captures
    length = length.to_i
    case direction
    when 'U'
      point1 = current.dup
      current.y += length
      point2 = current.dup
    when 'D'
      point1 = current.dup
      current.y -= length
      point2 = current.dup
    when 'L'
      point1 = current.dup
      current.x -= length
      point2 = current.dup
    when 'R'
      point1 = current.dup
      current.x += length
      point2 = current.dup
    end
    Segment.new(point1, point2)
  end
end

if $0 == __FILE__
  input = ARGF.readlines.map(&:strip)
  wire_1_path, wire_2_path, expected_part_1_answer, expected_part_2_answer = input
  wire_1 = Wire.parse(wire_1_path)
  wire_2 = Wire.parse(wire_2_path)
  intersections = Set.new
  wire_1.segments.each do |seg1|
    wire_2.segments.each do |seg2|
      intersections = intersections | seg1.intersections_with(seg2)
    end
  end

  part_1_closest = intersections.reject(&:origin?).map(&:manhattan_magnitude).min
  if expected_part_1_answer
    puts "Expected #{expected_part_1_answer}, got #{part_1_closest}"
  else
    puts part_1_closest
  end

  part_2_closest = intersections.reject(&:origin?).map { |intersection|
    wire_1.wire_distance_to(intersection) + wire_2.wire_distance_to(intersection)
  }.min
  if expected_part_2_answer
    puts "Expected #{expected_part_2_answer}, got #{part_2_closest}"
  else
    puts part_2_closest
  end
end
