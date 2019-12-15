class Point2
  attr_accessor :x, :y

  def initialize(x: 0, y: 0)
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
