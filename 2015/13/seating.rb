#!/usr/bin/env ruby

class Seating
  attr_accessor :chart

  def initialize(lines)
    @chart = parse_all(lines)
  end

  def parse(line)
    re = /(?<p1>\w+) would (?<plusminus>gain|lose) (?<points>\d+) happiness units by sitting next to (?<p2>\w+)./.freeze
    md = re.match(line)
    raise ArgumentError, "Unexpected format in '#{line}'" unless md
    [md['p1'], { md['p2'] => (md['plusminus'] == 'gain' ? 1 : -1) * md['points'].to_i }]
  end

  def parse_all(lines)
    c = lines.inject({}) { |collection, line|
      p1, d = parse(line)
      collection[p1] ||= { 'You' => 0 }
      collection[p1].merge!(d)
      collection
    }
    c['You'] = c.keys.each_with_object({}) { |p,o| o[p] = 0 }
    c
  end

  def participants
    chart.keys
  end

  def other_participants
    participants - %w(You)
  end

  def score(left, participant, right)
    chart[participant][left] + chart[participant][right]
  end

  def left_center_right(table, participant)
    pi = table.index(participant)
    [table[(pi + table.size - 1) % table.size], participant, table[(pi + 1) % table.size]]
  end

  def scores_without_you
    other_participants.permutation.map { |perm|
      perm.map { |p| score(*left_center_right(perm, p)) }.sum
    }
  end

  def scores_with_you
    participants.permutation.map { |perm|
      perm.map { |p| score(*left_center_right(perm, p)) }.sum
    }
  end

  def max_score_without_you
    scores_without_you.max
  end

  def max_score_with_you
    scores_with_you.max
  end
end

if $0 == __FILE__
  lines = ARGF.readlines.map(&:chomp)
  seating = Seating.new(lines)
  puts "Without you: #{seating.max_score_without_you}"
  puts "With you: #{seating.max_score_with_you}"
end
