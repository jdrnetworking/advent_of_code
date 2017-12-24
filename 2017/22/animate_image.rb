#!/usr/bin/env ruby

require 'rubygems'
require 'rmagick'
require 'optparse'
require_relative 'virus'

class Animation
  attr_accessor :cluster, :carrier, :options

  def initialize(grid, rules, **options)
    @options = options
    @cluster = Cluster.new(grid, width: @options[:grid_size], height: @options[:grid_size])
    @carrier = Carrier.new(cluster, rules)
    self
  end

  def image_size
    options[:grid_size] * options[:pixels_per_cell]
  end

  def current_image(percent_complete: 0)
    image = Magick::Image.new(image_size, image_size)
    pixels = cluster.grid.flat_map { |row|
      row.map { |cell|
        colormap[cell] * options[:pixels_per_cell]
      } * options[:pixels_per_cell]
    }.join
    if options[:show_progress]
      progress_pixels = (image_size * percent_complete).ceil
      progress_bar_pixels =
        colormap['progress'] * progress_pixels +
        colormap['.'] * (image_size - progress_pixels)
      pixels[-(3*image_size)..-1] = progress_bar_pixels
    end
    image.import_pixels(0, 0, image_size, image_size, 'RGB', pixels)
  end

  def colormap
    {
      '#' => "\x00\x00\x00",
      'W' => "\x66\x66\x66",
      'F' => "\xAA\xAA\xAA",
      '.' => "\xFF\xFF\xFF",
      'progress' => "\x00\x00\xFF"
    }
  end

  def write_frame
    current_image.write(options[:filename])
  end

  def write
    image_list = Magick::ImageList.new
    image_list << current_image
    frame_count = options[:iterations] / options[:iterations_per_frame]
    frame_count.times do |frame_index|
      options[:iterations_per_frame].times do
        carrier.burst
      end
      percent_complete = (frame_index + 1.0) / frame_count
      yield percent_complete if block_given?
      image_list << current_image(percent_complete: percent_complete)
    end
    image_list.delay = 1
    image_list.ticks_per_second = options[:frames_per_second]
    image_list.last.delay = options[:frames_per_second]
    image_list.write(options[:filename])
  end

  def self.default_options
    {
      grid_size: 50,
      filename: 'output.gif',
      pixels_per_cell: 10,
      iterations: 1000,
      iterations_per_frame: 5,
      frames_per_second: 15,
      show_progress: true
    }
  end
end

if $0 == __FILE__
  options = Animation.default_options.dup
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename($0)} [options] initial_grid.txt"

    opts.on('-g', '--grid-size CELLS', Integer, "Initial grid size (#{options[:grid_size]})") do |gs|
      options[:grid_size] = gs
    end

    opts.on('-o', '--output FILENAME', "Output filename (#{options[:filename]})") do |filename|
      options[:filename] = filename
    end

    opts.on('-p', '--pixels-per-cell PIXELS', Integer, "Pixels per cell (#{options[:pixels_per_cell]})") do |ppc|
      options[:pixels_per_cell] = ppc
    end

    opts.on('-i', '--iterations ITERATIONS', Integer, "Virus iterations to run (#{options[:iterations]})") do |i|
      options[:iterations] = i
    end

    opts.on('-I', '--iterations-per-frame ITERATIONS', Integer, "Iterations to compute between each image frame (#{options[:iterations_per_frame]})") do |ipf|
      options[:iterations_per_frame] = ipf
    end

    opts.on('-f', '--fps FRAMES', Integer, "Image frames per second (#{options[:frames_per_second]})") do |fps|
      options[:frames_per_second] = fps
    end

    opts.on('-p', '--[no-]progress', "Overlay progress at bottom of image (enabled)") do |p|
      options[:show_progress] = p
    end

    opts.on_tail('-h', '--help', 'Show this message') do
      puts opts
      exit 1
    end
  end
  parser.parse!

  if ARGV.size < 1
    puts parser
    exit 1
  end

  initial_grid = ARGF.readlines.map { |line| line.chomp.chars }
  animation = Animation.new(initial_grid, Carrier.rules_2, **options)
  animation.write do |percent_complete|
    pb_width = 50
    chars_on = (percent_complete * pb_width).ceil
    print "\r|" + ('-' * chars_on) + (' ' * (pb_width - chars_on)) + '|'
  end
  puts
end
