#!/usr/bin/env ruby

# Reference https://en.wikipedia.org/wiki/Taxicab_geometry
# Reference https://en.wikipedia.org/wiki/Ulam_spiral

class SpiralMemory
  attr_reader :grid, :size

  def initialize(size)
    @size = size
    initialize_grid
  end

  def size=(new_size)
    @size = new_size
    @size += 1 if @size.even?
    initialize_grid
  end

  def steps(location)
    x, y = xy(location - 1)
    x.abs + y.abs
  end

  def filled
    initialize_grid
    max = size**2
    (1..max).each { |location|
      x, y = xy(location - 1)
      grid[y+size/2] ||= []
      grid[y+size/2][x+size/2] = location
    }
    self
  end

  def up_to(location)
    self.size = Math.sqrt(location).ceil
    (1..location).each { |loc|
      x, y = xy(loc - 1)
      grid[y+size/2] ||= []
      grid[y+size/2][x+size/2] = loc
    }
    self
  end

  def sum_at(location)
    x, y = xy(location - 1)
    sum_surround(x+size/2, y+size/2)
  end

  def sum_surround(x, y)
    ((x-1)..(x+1)).sum { |_x|
      next 0 if _x < 0
      ((y-1)..(y+1)).sum { |_y|
        next 0 if _y < 0
        _x == x && _y == y ? 0 : grid.fetch(_y, []).fetch(_x, 0)
      }
    }
  end

  def with_sums
    initialize_grid
    max = size**2
    (1..max).each { |location|
      x, y = xy(location - 1)
      sum = location == 1 ? 1 : sum_surround(x+size/2, y+size/2)
      grid[y+size/2] ||= []
      grid[y+size/2][x+size/2] = sum
    }
    self
  end

  def initialize_grid
    @grid = Array.new(size) { Array.new(size, 0) }
    self
  end

  def inspect
    cell_width = grid.map { |row| row.map(&:to_s).map(&:length).max }.max + 1
    "\n" +
    grid.map { |row|
      Array(row).map { |cell|
        "%#{cell_width}s" % cell
      }.join
    }.join("\n")
  end

  # https://math.stackexchange.com/a/163093
  def xy(n)
    m = Math.sqrt(n).floor
    k = if m.odd?
          (m-1)/2
        elsif n >= m*(m+1)
          m / 2
        else
          m / 2 - 1
        end

    if n <= (2*k+1)**2
      [n-4*k**2-3*k, k]
    elsif n<=2*(k+1)*(2*k+1)
      [k+1,4*k**2+5*k+1-n]
    elsif n <= 4*(k+1)**2
      [4*k**2+7*k+3-n,-1*k-1]
    elsif n <= 2*(k+1)*(2*k+3)
      [-1*k-1, n-4*k**2-9*k-5]
    else
      [nil, nil]
    end
  end
end

if $0 == __FILE__
  grid = SpiralMemory.new.grid_up_to(Integer(ARGV.first))
  puts grid.inspect
  #puts SpiralMemory.new.sum_at(Integer(ARGV.first))
end
