#!/usr/bin/env ruby

require 'active_support/all'

class Reindeer
  def self.re
    /(?<name>.*) can fly (?<speed>\d+) km\/s for (?<endurance>\d+) seconds, but then must rest for (?<rest>\d+) seconds./.freeze
  end

  def self.parse(input)
    return nil unless (md = re.match(input))
    new(**md.named_captures.symbolize_keys)
  end

  attr_reader :name, :speed, :endurance, :rest

  def initialize(name:, speed:, endurance:, rest:)
    @name = name
    @speed = speed.to_i
    @endurance = endurance.to_i
    @rest = rest.to_i
  end

  def cycle_time
    endurance + rest
  end

  def distance_after(time)
    cycles = time / cycle_time
    cycle_distance = cycles * speed * endurance
    remainder = time % cycle_time
    remainder_distance = remainder < endurance ? remainder * speed : endurance * speed

    cycle_distance + remainder_distance
  end
end

if $0 == __FILE__
  if ARGV.size < 2
    STDERR.puts "Usage: #{File.basename $0} input_file time"
    exit 1
  end

  reindeer = File.readlines(ARGV[0]).map(&:chomp).map { |l| Reindeer.parse(l) }
  time = ARGV[1].to_i
  distances = reindeer.map { |r| [r.name, r.distance_after(time)] }.sort_by(&:last)
  winner, distance = distances.last
  puts "#{winner} wins after #{time} seconds at #{distance} km"

  scores = Hash.new(0)
  time.times do |checkpoint|
    progress = reindeer.map { |r| [r.name, r.distance_after(checkpoint + 1)] }.sort_by(&:last)
    lead_distance = progress.last.last
    progress.select { |_, distance| distance == lead_distance }.each { |name, _| scores[name] += 1 }
  end
  winning_score = scores.values.max
  winners = scores.select { |_, score| score == winning_score }.keys
  puts "#{winners.join(', ')} win(s) with a score of #{winning_score}"
end
