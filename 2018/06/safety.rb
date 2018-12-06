class Point
  attr_reader :row, :col, :label

  def initialize(row, col, label: nil)
    @row, @col = row, col
    @label = label
  end

  def distance_from(other)
    (row - other.row).abs + (col - other.col).abs
  end

  def to_s
    label
  end
end

def print_grid(grid)
  puts grid.size.times.map { |row|
    grid.first.size.times.map { |col|
      case grid[row][col]
      when nil
        "."
      else
        "%-1s" % grid[row][col].to_s
      end
    }.join
  }
end

points = ARGF.readlines.map.with_index { |row, index|
  Point.new(*row.scan(/\d+/).map(&:to_i), label: index)
}

max_row = points.map(&:row).max
max_col = points.map(&:col).max
grid = Array.new(max_row + 2) { Array.new(max_col + 2) }
points.each do |point|
  grid[point.row][point.col] = point
end
safe_points = 0
safe_threshold = 10000

grid.size.times do |row|
  grid.first.size.times do |col|
    here = Point.new(row, col)
    distances = points.each_with_object({}) { |point, o| o[point] = point.distance_from(here) }
    safe_points += 1 if distances.values.sum < safe_threshold
    min_distance = distances.values.min
    closest = distances.select { |_, d| d == min_distance }.keys
    if closest.size == 1
      grid[row][col] = closest.first.label
    end
  end
end

finite_points = points.reject { |point|
  grid.first.any? { |c| c == point || c == point.label } ||
    grid.last.any? { |c| c == point || c == point.label } ||
    grid.map(&:first).any? { |c| c == point || c == point.label } ||
    grid.map(&:last).any? { |c| c == point || c == point.label }
}

distances = finite_points.each_with_object({}) do |point, o|
  o[point] = grid.sum { |row| row.count { |cell| cell == point || cell == point.label } }
end

largest_finite_area = distances.values.max
puts "Part 1: #{largest_finite_area}"
puts "Part 2: #{safe_points}"
