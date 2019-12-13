class InfiniteGrid
  attr_reader :grid, :display_mapping
  attr_accessor :base_x, :base_y, :inverted

  def initialize(display_mapping: {nil => ' ', 0 => '.', 1 => '#'}, inverted: false)
    @grid = [[nil]]
    @base_x, @base_y = 0, 0
    @display_mapping = display_mapping
    @inverted = inverted
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
  end

  def to_s
    (inverted ? grid.reverse : grid).map { |row|
      row.map { |cell| display_mapping[cell] }.join
    }.join("\n")
  end

  def specified_cell_count
    grid.sum { |row| row.compact.size }
  end
end
