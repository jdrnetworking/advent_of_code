#!/usr/bin/env ruby

require_relative '../10/knot_hash.rb'
require 'active_support/core_ext/object/deep_dup'

class Disk
  attr_accessor :key, :width, :height

  def initialize(key, size_or_width = 128, height = nil)
    @key = key
    @width = size_or_width
    @height = height || size_or_width
  end

  def used
    grid.sum { |row| row.count { |cell| cell } }
  end

  def grid
    height.times.map { |row|
      [KnotHash.digest("#{key}-#{row}")].pack('H*').unpack('B*').first[0,width]
    }.map { |row|
      row.chars.map { |cell| cell == '1' }
    }
  end

  def region_count
    regions.inject(&:+).compact.uniq.size
  end

  def regions
    _grid = grid.deep_dup
    current_region = 1
    height.times do |row_index|
      width.times do |col_index|
        if _grid[row_index][col_index] == false
          _grid[row_index][col_index] = nil
        elsif _grid[row_index][col_index] == true
          _grid[row_index][col_index] = current_region
          go_viral(_grid, row_index, col_index, current_region)
          current_region += 1
        end
      end
    end
    _grid
  end

  def go_viral(_grid, row_index, col_index, current_region)
    # up
    if row_index > 0 && _grid[row_index - 1][col_index] == true
      _grid[row_index - 1][col_index] = current_region
      go_viral(_grid, row_index - 1, col_index, current_region)
    end

    # left
    if col_index > 0 && _grid[row_index][col_index - 1] == true
      _grid[row_index][col_index - 1] = current_region
      go_viral(_grid, row_index, col_index - 1, current_region)
    end

    # down
    if row_index < _grid.size - 1 && _grid[row_index + 1][col_index] == true
      _grid[row_index + 1][col_index] = current_region
      go_viral(_grid, row_index + 1, col_index, current_region)
    end

    # right
    if col_index < _grid[row_index].size - 1 && _grid[row_index][col_index + 1] == true
      _grid[row_index][col_index + 1] = current_region
      go_viral(_grid, row_index, col_index + 1, current_region)
    end
  end
end

if $0 == __FILE__
  key = ARGV.first
  disk = Disk.new(key)
  puts "Used squares: #{disk.used}"
  puts "Regions: #{disk.region_count}"
end
