#!/usr/bin/env ruby

class Fractal
  attr_accessor :pixels, :rules

  def initialize(rule_strings)
    @pixels = [
      %w(. # .),
      %w(. . #),
      %w(# # #)
    ]
    @rules = rule_strings.map { |string| Rule.parse(string) }
  end

  def size
    pixels.size
  end

  def pixels_on
    pixels.flatten.group_by(&:itself).transform_values(&:size)['#']
  end

  def iterate(times = 1)
    times.times do
      chunk_size = size.even? ? 2 : 3
      self.pixels = chunk(chunk_size).map { |chunk_row|
        concatenate_chunks(
          *chunk_row.map { |chunk|
            transform(chunk)
          }
        )
      }.inject(&:+)
    end
    self
  end

  def chunk(chunk_size)
    pixels.each_slice(chunk_size).map { |rows|
      rows.first.each_slice(chunk_size).map.with_index { |_, index|
        rows.map { |row| row[chunk_size * index, chunk_size] }
      }
    }
  end

  def concatenate_chunks(*chunks)
    c1, *c2 = *chunks
    c1.zip(*c2).map  { |c| c.inject(&:+) }
  end

  def transform(matrix)
    rules.detect { |rule| rule.match?(matrix) }&.output or
      raise ArgumentError, "No rule matches: #{matrix.map(&:join).join(?/)}"
  end

  def to_s
    pixels.map { |row|
      row.map { |pixel|
        pixel
      }.join
    }.join("\n")
  end

  def inspect
    to_s
  end

  class Rule
    attr_accessor :pattern, :output

    def initialize(pattern, output)
      @pattern = pattern
      @output = output
    end

    def to_s
      "#{pattern.map(&:join).join(?/)} => #{output.map(&:join).join(?/)}"
    end

    def inspect
      to_s
    end

    def match?(input)
      pattern == input ||
        rotate(pattern) == input ||
        rotate(pattern, 2) == input ||
        rotate(pattern, 3) == input ||
        flip_h(pattern) == input ||
        flip_v(pattern) == input ||
        rotate(flip_h(pattern)) == input ||
        rotate(flip_v(pattern)) == input
    end

    def rotate(matrix, times = 1)
      times.times.inject(matrix) { |m,_|
        flip_h(m.transpose)
      }
    end

    def flip_h(matrix)
      matrix.map(&:reverse)
    end

    def flip_v(matrix)
      matrix.reverse
    end

    def self.parse(line)
      (md = /(?<pattern>([.#]+\/)+([.#]+)) => (?<output>([.#]+\/)+([.#]+))/.match(line)) &&
        new(md[:pattern].split(?/).map(&:chars), md[:output].split(?/).map(&:chars))
    end
  end
end

class Fractifier
  attr_accessor :fractal, :iterations, :options

  def initialize(fractal, iterations, **options)
    @fractal = fractal
    @iterations = iterations
    @options = {
      fg_color: "\0\0\0",
      bg_color: "\xFF\xFF\xFF",
      delay: 1,
      frame_rate: 3,
      final_dwell: 6
    }.merge(options)
  end

  def size
    @size ||= begin
                sizes = (1..iterations).each_with_object([3]) { |iteration, s|
                  s << ((iteration % 3 == 1) ? (s.last * 4 / 3) : (s.last * 3 / 2))
                }
                optimal = sizes.last
                loop do
                  remainders = sizes.map { |_size| optimal % _size }
                  break if remainders.all?(&:zero?)
                  largest_misfit = sizes.zip(remainders).reject { |_,r| r.zero? }.last.first
                  optimal = largest_misfit.lcm(sizes.last)
                end
                optimal
              end
  end

  def iterate
    fractal.iterate
  end

  def current_image
    image = Magick::Image.new(size, size)
    pixel_multiplier = size / fractal.size
    pixels = fractal.pixels.flat_map { |row|
      row.map { |cell|
        (cell == '#' ? options[:fg_color] : options[:bg_color]) * pixel_multiplier
      } * pixel_multiplier
    }.join
    image.import_pixels(0, 0, size, size, 'RGB', pixels)
  end

  def write(filename)
    image_list = Magick::ImageList.new
    image_list << current_image
    iterations.times do |iteration|
      fractal.iterate
      image_list << current_image
    end
    image_list.delay = options[:delay]
    image_list.ticks_per_second = options[:frame_rate]
    image_list.last.delay = options[:final_dwell] || options[:delay]
    image_list.write(filename)
  end
end

if $0 == __FILE__
  if ARGV.size.zero?
    puts "Usage: #{$0} iterations rules_file [image_filename.gif]"
    exit 1
  end

  iterations = ARGV.shift.to_i
  if ARGV.size > 1
    require 'rubygems'
    require 'rmagick'

    image_filename = ARGV.pop
    rule_strings = ARGF.readlines.map(&:chomp)
    fractal = Fractal.new(rule_strings)
    fractifier = Fractifier.new(fractal, iterations)
    fractifier.write(image_filename)
    puts "#{fractal.pixels_on} pixels on after #{iterations} iterations"
  else
    rule_strings = ARGF.readlines.map(&:chomp)
    fractal = Fractal.new(rule_strings)
    fractal.iterate(iterations)
    puts "#{fractal.pixels_on} pixels on after #{iterations} iterations"
  end
end
