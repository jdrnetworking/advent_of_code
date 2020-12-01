def power_level(x, y, serial)
  rack_id = x + 10
  level = rack_id * y
  level += serial
  level *= rack_id
  level = level.to_s.chars.reverse[2].to_i
  level - 5
end

def max(width = 300, height = 300, serial)
  max_level = -Float::INFINITY
  max_x, max_y = nil, nil
  grid = (1..(width - 2)).map { |x|
    (1..(height - 2)).map { |y|
      l = 3.times.sum { |dx| 3.times.sum { |dy| power_level(x + dx, y + dy, serial) } }
      max_level, max_x, max_y = l, x, y if l > max_level
    }
  }
  [max_x, max_y]
end

def print_grid(offset_x, offset_y, width, height, serial)
  puts height.times.map { |y|
    ("%-4d"*width) % width.times.map { |x|
      power_level(x + offset_x, y + offset_y, serial)
    }
  }.join("\n")
end
