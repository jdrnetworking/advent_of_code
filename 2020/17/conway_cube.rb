#!/usr/bin/env ruby

class Cuboid
  attr_reader :cells

  def initialize(init)
    @cells = init
  end

  def conway(rules)
    Cuboid.new(
      cells.map.with_index { |layer, layer_index|
        layer.map.with_index { |row, row_index|
          row.map.with_index { |cell, cell_index|
            rules[cell, count_neighbors(layer_index, row_index, cell_index)]
          }
        }
      }
    )
  end

  def count_neighbors(layer, row, cell)
    ([layer - 1, 0].max..[layer + 1, size - 1].min).sum { |layer_index|
      ([row - 1, 0].max..[row + 1, cells[layer].size - 1].min).sum { |row_index|
        ([cell - 1, 0].max..[cell + 1, cells[layer][row].size - 1].min).count { |cell_index|
          cells[layer_index][row_index][cell_index] &&
            !(layer_index == layer && row_index == row && cell_index == cell)
        }
      }
    }
  end

  def count_active
    cells.sum { |layer|
      layer.sum { |row|
        row.count(&:itself)
      }
    }
  end

  def layer_to_s(layer, states: { true => '#', false => '.' })
    raise IndexError, "#{layer} is not a valid layer" unless (0...cells.size).cover?(layer)

    cells[layer].map { |row|
      row.map { |cell| states[cell] }.join
    }.join("\n")
  end

  def [](index)
    cells[index]
  end

  def size
    cells.size
  end

  def inspect
    "#<#{self.class}:#{object_id.to_s(16)} #{cells.size}x#{cells.first.size}x#{cells.first.first.size}>"
  end

  def self.parse(input, padding: 0, states: { '#' => true, '.' => false, default: false })
    parsed = input.split.map { |line| line.chomp.chars.map { |char| states[char] } }
    row_count = parsed.size
    row_size = parsed.first.size
    new(
      padding.times.map { fill_layer(row_count + 2 * padding, row_size + 2 * padding, states[:default]) } +
        [
          padding.times.map { fill_row(row_size + 2 * padding, states[:default]) } +
            parsed.map { |row|
              fill_row(padding, states[:default]) + row + fill_row(padding, states[:default])
            } +
            padding.times.map { fill_row(row_size + 2 * padding, states[:default]) }
        ] +
        padding.times.map { fill_layer(row_count + 2 * padding, row_size + 2 * padding, states[:default]) }
    )
  end

  def self.fill_layer(rows, columns, state)
    rows.times.map { fill_row(columns, state) }
  end

  def self.fill_row(columns, state)
    columns.times.map { state }
  end
end

class Hypercuboid < Cuboid
  def conway(rules)
    Hypercuboid.new(
      cells.map.with_index { |dimension, dimension_index|
        dimension.map.with_index { |layer, layer_index|
          layer.map.with_index { |row, row_index|
            row.map.with_index { |cell, cell_index|
              rules[cell, count_neighbors(dimension_index, layer_index, row_index, cell_index)]
            }
          }
        }
      }
    )
  end

  def count_neighbors(dimension, layer, row, cell)
    ([dimension - 1, 0].max..[dimension + 1, cells.size - 1].min).sum { |dimension_index|
      ([layer - 1, 0].max..[layer + 1, cells[dimension].size - 1].min).sum { |layer_index|
        ([row - 1, 0].max..[row + 1, cells[dimension][layer].size - 1].min).sum { |row_index|
          ([cell - 1, 0].max..[cell + 1, cells[dimension][layer][row].size - 1].min).count { |cell_index|
            cells[dimension_index][layer_index][row_index][cell_index] &&
              !(dimension_index == dimension && layer_index == layer && row_index == row && cell_index == cell)
          }
        }
      }
    }
  end

  def count_active
    cells.sum { |dimension|
      dimension.sum { |layer|
        layer.sum { |row|
          row.count(&:itself)
        }
      }
    }
  end

  def inspect
    "#<#{self.class}:#{object_id.to_s(16)} #{cells.size}x#{cells.first.size}x#{cells.first.first.size}x#{cells.first.first.first.size}>"
  end

  def self.parse(input, padding: 0, states: { '#' => true, '.' => false, default: false })
    parsed = input.split.map { |line| line.chomp.chars.map { |char| states[char] } }
    layer_count = 1
    row_count = parsed.size
    row_size = parsed.first.size
    new(
      padding.times.map { fill_dimension(layer_count + 2 * padding, row_count + 2 * padding, row_size + 2 * padding, states[:default]) } +
        [
          padding.times.map { fill_layer(row_count + 2 * padding, row_size + 2 * padding, states[:default]) } +
            [
              padding.times.map { fill_row(row_size + 2 * padding, states[:default]) } +
                parsed.map { |row|
                  fill_row(padding, states[:default]) + row + fill_row(padding, states[:default])
                } +
                padding.times.map { fill_row(row_size + 2 * padding, states[:default]) }
            ] +
            padding.times.map { fill_layer(row_count + 2 * padding, row_size + 2 * padding, states[:default]) }
        ] +
        padding.times.map { fill_dimension(layer_count + 2 * padding, row_count + 2 * padding, row_size + 2 * padding, states[:default]) }
    )
  end

  def self.fill_dimension(layers, rows, columns, state)
    layers.times.map { fill_layer(rows, columns, state) }
  end
end

def rules_of_life
  -> (state, active_neighbors) {
    (state && (2..3).cover?(active_neighbors)) ||
      (!state && active_neighbors == 3)
  }
end

if $0 == __FILE__
  input = File.read(ARGV[0])
  iterations = ARGV[1].to_i
  cube = Cuboid.parse(input, padding: iterations)
  cube = iterations.times.reduce(cube) { |cube, _| cube.conway(rules_of_life) }
  puts cube.count_active

  hypercube = Hypercuboid.parse(input, padding: iterations)
  hypercube = iterations.times.reduce(hypercube) { |hypercube, _| hypercube.conway(rules_of_life) }
  puts hypercube.count_active
end
