require_relative './point2'

class Point3 < Point2
  attr_accessor :z

  def initialize(x: 0, y: 0, z: 0)
    super
    @z = z
  end

  def origin?
    super && z.zero?
  end

  def manhattan_magnitude
    super + z.abs
  end

  def distance_to(other)
    super + (z - other.z).abs
  end

  def inspect
    "#<Point [#{x},#{y}],#{z}>"
  end

  def ==(other)
    super && z == other.z
  end
end
