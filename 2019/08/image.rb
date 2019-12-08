#!/usr/bin/env ruby

class Image
  attr_accessor :width, :height
  attr_reader :pixel_data

  def initialize(width, height, pixel_data)
    @width = width
    @height = height
    @pixel_data = pixel_data
  end

  def layers
    pixel_data.chars.each_slice(area).to_a
  end

  def distribution
    layers.map { |pixels|
      pixels.group_by(&:itself).transform_values(&:count)
    }
  end

  def area
    width * height
  end

  def checksum
    selected = distribution.min_by { |layer| layer.fetch('0', 0) }
    selected.fetch('1', 0) * selected.fetch('2', 0)
  end

  def to_s
    pixelize(distilled)
  end

  def distilled
    layers.reverse.inject { |final,upper|
      final.map.with_index { |existing, i|
        upper[i] == '2' ? final[i] : upper[i]
      }
    }
  end

  def pixelize(pixels)
    pixels.each_slice(width).map { |row|
      row.map { |pixel|
        case pixel
        when '0' then ' '
        when '1' then '█'
        when '2' then ' '
        end
      }.join
    }.join("\n")
  end

  def self.from_file(filename)
    width, height, pixel_data = File.readlines(filename).map(&:strip)
    new(width.to_i, height.to_i, pixel_data)
  end
end

if $0 == __FILE__
  image = Image.from_file(ARGV[0])
  puts "Part 1: #{image.checksum}"
  puts "Part 2:\n#{image}"
end
