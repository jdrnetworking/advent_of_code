#!/usr/bin/env ruby

def parse(input)
  validations, own, nearby = input.split(/(?:\r?\n){2}/)
  validations = validations.split(/\r?\n/).each_with_object({}) { |line, o|
    md = line.match(/(?<field>[\w ]+):\s+(?<r1>\d+)-(?<r2>\d+) or (?<r3>\d+)-(?<r4>\d+)/)
    o[md[:field]] = [(md[:r1].to_i..md[:r2].to_i), (md[:r3].to_i..md[:r4].to_i)]
  }
  own = own.scan(/\d+/).map(&:to_i)
  nearby = nearby.scan(/[\d,]+/).map { |ticket| ticket.split(',').map(&:to_i) }

  {
    validations: validations,
    own: own,
    nearby: nearby,
  }
end

def invalid_ticket?(ticket, validations)
  ticket.any? { |value| !valid_for_any_field?(value, validations) }
end

def valid_for_any_field?(value, validations)
  validations.any? { |field, ranges|
    ranges.any? { |r| r.cover?(value) }
  }
end

def potential_fields(tickets, validations)
  tickets
    .reject { |ticket| invalid_ticket?(ticket, validations) }
    .map { |ticket|
      ticket.map { |value|
        validations.map { |field, ranges| field if ranges.any? { |r| r.cover?(value) } }.compact
      }
    }
    .reduce { |acc, ticket| acc.map.with_index { |field, index| field & ticket[index] } }
end

def ad_reductum(fields)
  loop do
    fields.each_with_index do |field, index|
      if field.size == 1
        (fields.size.times.to_a - [index]).each do |other_index|
          fields[other_index] -= [field.first]
        end
      end
    end
    break if fields.all? { |field| field.size == 1 }
  end
  fields.map(&:first)
end

def map_ticket(fields, values)
  fields.zip(values).to_h
end

if $0 == __FILE__
  input = parse(ARGF.read)
  puts input[:nearby].flatten.select { |value| !valid_for_any_field?(value, input[:validations]) }.sum

  valid_tickets = ([input[:own]] + input[:nearby]).reject { |ticket| invalid_ticket?(ticket, input[:validations]) }
  fields = potential_fields(valid_tickets, input[:validations])
  fields = ad_reductum(fields)
  relevant_fields = map_ticket(fields, input[:own]).select { |field, value| field.start_with?('departure') }
  puts relevant_fields.values.reduce(:*)
end
