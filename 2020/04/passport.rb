#!/usr/bin/env ruby

require 'set'

FIELDS = %w[
  byr
  iyr
  eyr
  hgt
  hcl
  ecl
  pid
  cid
]
FIELD_MATCHER = Regexp.new("(?:(#{FIELDS.join('|')}):([^\s]+)(?:\s+|$))", Regexp::MULTILINE)
REQUIRED_FIELDS = Set.new(FIELDS - ['cid'])

def parse(data)
  field_sets = data.split(/(?:\r?\n){2}/).map { |field_set|
    field_set.split.join(' ').scan(FIELD_MATCHER).to_h
  }
end

def has_required_fields?(field_set)
  Set.new(field_set.keys) >= REQUIRED_FIELDS
end

def valid_fields?(field_set)
  field_set.all? { |field, value|
    case field
    when 'byr'
      int_in_regexp?(value, /\A(\d{4})\z/, min: 1920, max: 2002)
    when 'iyr'
      int_in_regexp?(value, /\A(\d{4})\z/, min: 2010, max: 2020)
    when 'eyr'
      int_in_regexp?(value, /\A(\d{4})\z/, min: 2020, max: 2030)
    when 'hgt'
      int_in_regexp?(value, /\A(\d+)cm\z/, min: 150, max: 193) ||
        int_in_regexp?(value, /\A(\d+)in\z/, min: 59, max: 76)
    when 'hcl'
      value =~ /\A#\h{6}\z/
    when 'ecl'
      value =~ /\A(amb|blu|brn|gry|grn|hzl|oth)\z/
    when 'pid'
      value =~ /\A\d{9}\z/
    when 'cid'
      true
    else
      raise ArgumentError, "Unexpected field '#{field}'"
    end
  }
end

def int_in_regexp?(value, regexp, min:, max:)
  md = value.match(regexp)
  return false unless md
  (min..max).cover?(md[1].to_i)
end

if $0 == __FILE__
  field_data = parse(ARGF.read)
  puts field_data.count { |field_set| has_required_fields?(field_set) }
  puts field_data.count { |field_set| has_required_fields?(field_set) && valid_fields?(field_set) }
end
