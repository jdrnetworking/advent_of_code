class InfiniteGrid
  attr_reader :grid, :display_mapping
  attr_accessor :base_x, :base_y, :inverted, :width, :height

  def initialize(display_mapping: {0 => '.', 1 => '#'}, inverted: false)
    @grid = [[nil]]
    @base_x, @base_y = 0, 0
    @width, @height = 1, 1
    @display_mapping = display_mapping
    @inverted = inverted # inverted mean smaller y is displayed at the top
  end

  def [](x, y)
    return nil if y < -base_y || x < -base_x
    (grid[y + base_y] || [])[x + base_x]
  end

  def []=(x, y, val)
    if y < -base_y
      (-y - base_y).times do
        grid.unshift([])
      end
      self.base_y = -y
    end
    if x < -base_x
      grid.size.times do |iy|
        (-x - base_x).times do
          grid[iy].unshift(nil)
        end
      end
      self.base_x = -x
    end
    grid[y + base_y] ||= []
    grid[y + base_y][x + base_x] = val
    self.height = grid.size
    self.width = grid.map(&:size).max
  end

  def inverted?
    @inverted
  end

  def each
    height.times { |relative_y|
      y = relative_y - base_y
      width.times { |relative_x|
        x = relative_x - base_x
        value = self[x,y]
        yield x, y, value
      }
    }
  end

  def to_a
    rows = height.times.map { |relative_y|
      y = relative_y - base_y
      width.times.map { |relative_x|
        x = relative_x - base_x
        self[x,y]
      }
    }
    (inverted? ? rows : rows.reverse)
  end

  def to_s(default: ' ', overrides: {}) # { [x,y] => '?' }
    rows = height.times.map { |relative_y|
      y = relative_y - base_y
      width.times.map { |relative_x|
        x = relative_x - base_x
        value = self[x,y]
        overrides.fetch([x, y], display_mapping.fetch(value, default))
      }.join
    }
    (inverted? ? rows : rows.reverse).join("\n")
  end

  def gsub!(&block)
    each do |x, y, value|
      self[x, y] = block.call(x, y, value)
    end
  end

  def specified_cell_count(values: [])
    grid.sum { |row| values.empty? ? row.compact.size : row.count { |c| values.include?(c) } }
  end
end
