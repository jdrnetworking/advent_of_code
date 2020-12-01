#!/usr/bin/env ruby

require_relative './lib/bios'
require 'pry-byebug'

class FFT
  attr_accessor :seed

  def initialize(seed)
    @seed = seed
  end

  def output(phase_count)
    phase_count.times.inject(seed) { |input, round|
      input.size.times.map { |position|
        modulation = modulator.zip(*(position.times.map { modulator })).flatten.cycle
        modulation.next
        product = input.chars.map { |digit|
          digit.to_i * modulation.next
        }.inject(&:+)
        (product.abs % 10).to_s
      }.join
    }
  end

  def modulator
    [0, 1, 0, -1]
  end
end

if $0 == __FILE__
  input, control = ARGF.readlines.map(&:strip)
  signal_multiplier, phase_count, expected = control.split(',')
  signal_multiplier = signal_multiplier.to_i
  phase_count = phase_count.to_i
  input *= signal_multiplier

  fft = FFT.new(input)
  part_1 = fft.output(phase_count)[0,8]
  BIOS.assert_or_print(expected, part_1, label: 'Part 1')
end
