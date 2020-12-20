#!/usr/bin/env ruby

class Image
  attr_reader :pixels

  def self.parse(input)
    new(input.split(/\n/).map(&:chars))
  end

  def initialize(pixels)
    @pixels = pixels
  end

  def width
    @pixels.first&.size || 0
  end

  def height
    @pixels&.size || 0
  end

  def to_s
    pixels.map { |row| row.join }.join("\n")
  end

  def flip
    Image.new(pixels.reverse)
  end

  def rotate
    Image.new(pixels.transpose).flip
  end

  def count_pixels(value)
    pixels.flat_map(&:itself).count { |c| c == value }
  end

  def find_pixels(pixel_value)
    pixels.flat_map.with_index { |row, row_index|
      row.map.with_index { |value, col_index|
        next unless value == pixel_value
        [row_index, col_index]
      }.compact
    }
  end

  def find_mask(mask_image, mask_char: '#')
    return [] if width < mask_image.width || height < mask_image.height
    (0..(height - mask_image.height)).to_a.product((0..(width - mask_image.width)).to_a).select { |r, c|
      mask_at_offset?(mask_image, r, c, mask_char)
    }
  end

  def mask_at_offset?(mask_image, r, c, mask_char)
    mask_image.find_pixels(mask_char).all? { |offset_r, offset_c| pixels[r + offset_r][c + offset_c] == mask_char }
  end

  def apply_mask!(mask_image, r, c, mask_chars: { '#' => 'O' })
    mask_chars.each do |from, to|
      mask_image.find_pixels(from).each do |offset_r, offset_c|
        pixels[r + offset_r][c + offset_c] = to
      end
    end
    self
  end

  def ==(other)
    pixels == other.pixels
  end

  def inspect
    "#<#{self.class.name}:#{object_id} #{width}x#{height}>"
  end
end

class TileSet
  attr_reader :tiles

  def self.parse(input)
    new(input.split(/\n\n/).map { |tile_input| Tile.parse(tile_input) })
  end

  def initialize(tiles)
    @tiles = tiles
  end

  def connect!
    tiles.each do |tile|
      other_tiles = tiles - [tile]
      tile.edges.each do |edge|
        next if edge.connected?
        other = other_tiles.flat_map(&:edges).reject(&:connected?).detect { |other|
          edge.matches?(other) || edge.matches_flipped?(other)
        }
        edge.connect!(other) if other
      end
    end
  end

  def orient!
    tiles.first.oriented = true
    working_set = [tiles.first]
    until working_set.empty? do
      working_tile = working_set.shift
      working_tile.edges.each_with_index do |edge, direction|
        next unless (other_tile = edge.neighbor&.tile)
        next if other_tile.oriented?
        other_tile.orient_to(edge, direction)
        working_set.push(other_tile)
      end
    end
  end

  def pixels
    first_tile = corner_tiles.detect { |tile| tile.neighbors[Tile::NORTH].nil? && tile.neighbors[Tile::WEST].nil? }
    pixels = []
    while first_tile do
      tile = first_tile
      row_pixels = tile.pixels.map(&:dup)
      while (tile = tile.neighbors[Tile::EAST]) do
        row_pixels.each_with_index do |row, row_index|
          row.concat(tile.pixels[row_index])
        end
      end
      pixels.concat(row_pixels)
      first_tile = first_tile.neighbors[Tile::SOUTH]
    end
    pixels
  end

  def corner_tiles
    tiles.select(&:corner?)
  end
end

class Tile
  NORTH, EAST, SOUTH, WEST = 0, 1, 2, 3

  attr_reader :id, :pixels, :edges
  attr_accessor :oriented

  def self.parse(tile_input)
    tile_id, *pixel_rows = tile_input.split(/\n/)
    new(tile_id[/\d+/].to_i, pixel_rows.map(&:chars))
  end

  def initialize(id, pixels)
    @id = id
    @oriented = false
    @edges = extract_edges(pixels)
    @pixels = remove_borders(pixels)
  end

  def neighbors
    edges.map { |edge| edge.neighbor&.tile }
  end

  def corner?
    neighbors.compact.size == 2
  end

  def edge?
    neighbors.compact.size == 3
  end

  def interior?
    neighbors.compact.size == 4
  end

  def oriented?
    @oriented
  end

  def orient_to(edge, direction)
    complementary_direction = (direction + 2) % 4
    rotate! until edges[complementary_direction].neighbor == edge
    if [NORTH, SOUTH].include?(direction)
      flip_horizontal! unless edges[complementary_direction].matches?(edge)
    else
      flip_vertical! unless edges[complementary_direction].matches?(edge)
    end
    @oriented = true
  end

  def rotate!
    @pixels = pixels.transpose.map(&:reverse)
    edges.unshift(edges.pop)
  end

  def flip_horizontal!
    pixels.each(&:reverse!)
    edges[EAST], edges[WEST] = edges[WEST], edges[EAST]
    edges.each(&:flip!)
  end

  def flip_vertical!
    pixels.reverse!
    edges[NORTH], edges[SOUTH] = edges[SOUTH], edges[NORTH]
    edges.each(&:flip!)
  end

  def inspect
    "#<#{self.class.name}:id=#{@id} neighbors=[#{neighbors.compact.size}] oriented=#{@oriented ? '🟢' : '🔴'}>"
  end

  private

  def extract_edges(pixels)
    [
      Edge.new(self, pixels.first.dup),
      Edge.new(self, pixels.map(&:last)),
      Edge.new(self, pixels.last.reverse),
      Edge.new(self, pixels.map(&:first).reverse),
    ]
  end

  def remove_borders(pixels)
    pixels[1..-2].map { |p| p[1..-2] }
  end
end

class Edge
  attr_reader :pixels, :tile
  attr_accessor :neighbor

  def initialize(tile, pixels)
    @tile = tile
    @pixels = pixels
  end

  def flip!
    pixels.reverse!
  end

  def matches?(other)
    pixels == other.pixels.reverse
  end

  def matches_flipped?(other)
    pixels == other.pixels
  end

  def connected?
    !neighbor.nil?
  end

  def connect!(other)
    self.neighbor = other
    other.neighbor = self
  end

  def [](index)
    pixels[index]
  end

  def inspect
    "#<#{self.class} tile=#{tile.id} pixels=#{pixels.join}>"
  end
end

def print_tile(tile, with_edges: true)
  pixels = if with_edges
             [tile.edges[Tile::NORTH].pixels.join] +
               tile.pixels.map.with_index(1) { |row, row_index| ([tile.edges[Tile::WEST].pixels.reverse[row_index]] + row + [tile.edges[Tile::EAST][row_index]]).join } +
               [tile.edges[Tile::SOUTH].pixels.reverse.join]
           else
             tile.pixels.map(&:join).join("\n")
           end
  puts pixels
end

if $0 == __FILE__
  if ARGV.empty?
    puts "Usage: #{$0} tile_data.txt [sea_creature.txt]"
    exit 1
  end

  tile_set = TileSet.parse(File.read(ARGV[0]))
  tile_set.connect!
  tile_set.orient!
  puts tile_set.corner_tiles.map(&:id).reduce(:*)

  if ARGV.size > 1
    image = Image.new(tile_set.pixels)
    sea_creature = Image.parse(File.read(ARGV[1]))
    coordinates = 4.times {
      coords = image.find_mask(sea_creature)
      break coords unless coords.empty?
      image = image.rotate
    }
    if coordinates.nil?
      image = image.flip
      coordinates = 4.times {
        coords = image.find_mask(sea_creature)
        break coords unless coords.empty?
        image = image.rotate
      }
    end
    if coordinates.nil?
      puts "No sea creature found"
      exit
    end
    coordinates.each { |r, c| image.apply_mask!(sea_creature, r, c) }
    puts image.count_pixels('#')
  end
end
