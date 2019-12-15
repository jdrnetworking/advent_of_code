#!/usr/bin/env ruby

require_relative './lib/bios'
require_relative './lib/computer'

if $0 == __FILE__
  mode, available_phase_settings, memory, expected = ARGF.readlines.map(&:strip)
  expected = expected.to_i if expected
  available_phase_settings = available_phase_settings.chars.map(&:to_i)
  memory = memory.split(',').map(&:to_i)

  case mode
  when 'linear'
    max = 0
    available_phase_settings.permutation.each do |phase_settings|
      thrust_setting = phase_settings.inject(0) { |previous_output,phase_setting|
        computer = Computer.new(memory, Queue.new << phase_setting << previous_output, Queue.new)
        computer.compute!
        computer.outputs.pop
      }
      if thrust_setting > max
        max = thrust_setting
      end
    end
  when 'feedback'
    max = 0
    available_phase_settings.permutation.each do |phase_settings|
      pipes = phase_settings.map { |phase_setting| Queue.new << phase_setting }
      pipes[0] << 0
      computers = 5.times.map { |i|
        Thread.new do
          Computer.new(memory, pipes[i], pipes[(i + 1) % 5], name: i).compute!
        end
      }
      computers.each(&:join)
      thrust_setting = pipes[0].pop
      if thrust_setting > max
        max = thrust_setting
      end
    end
  else
    raise ArgumentError, "Unexpected mode '#{mode}'"
  end

  BIOS.assert_or_print(expected, max)
end
