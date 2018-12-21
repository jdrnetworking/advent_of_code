class XY
  attr_accessor :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def +(other)
    self.class.new(x + other.x, y + other.y)
  end

  def *(multiplicand)
    self.class.new(x * multiplicand, y * multiplicand)
  end
end

class Point
  attr_accessor :position, :velocity

  def initialize(position, velocity)
    @position = position
    @velocity = velocity
  end

  def move(steps = 1)
    self.position = position + velocity * steps
  end

  def self.parse(input)
    pattern = /position=<\s*(-?\d+),\s*(-?\d+)> velocity=<\s*(-?\d+),\s*(-?\d+)>/
    raise ArgumentError unless (md = pattern.match(input))
    position = XY.new(Integer(md[1]), Integer(md[2]))
    velocity = XY.new(Integer(md[3]), Integer(md[4]))
    new(position, velocity)
  end

  def at?(x, y)
    position.x == x && position.y == y
  end
end

class Message
  attr_reader :points, :grid, :age

  def initialize(points)
    @points = points.dup
    @age = 0
  end

  def self.parse(inputs)
    new(inputs.map { |input| Point.parse(input) })
  end

  def self.load_file(filename)
    parse(File.readlines(filename))
  end

  def print(x: nil, y: nil, width: nil, height: nil)
    x ||= start_x
    y ||= start_y
    width ||= self.width
    height ||= self.height

    puts (y..(y + height)).map { |y|
      (x..(x + width)).map { |x|
        point_at?(x, y) ? '#' : '.'
      }.join
    }
  end

  def size
    [width, height]
  end

  def start_x
    points.map { |point| point.position.x }.min
  end

  def start_y
    points.map { |point| point.position.y }.min
  end

  def width
    points.map { |point| point.position.x }.max - start_x
  end

  def height
    points.map { |point| point.position.y }.max - start_y
  end

  def move(steps = 1)
    points.each do |point|
      point.move(steps)
    end
    @age += steps
    size
  end

  def move_until_size(w, h)
    move until size == [w, h]
    age
  end

  private

  def point_at?(x, y)
    points.any? { |point| point.at?(x, y) }
  end
end
