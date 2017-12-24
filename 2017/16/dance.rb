#!/usr/bin/env ruby

module Dance
  SPIN = /s(\d+)/
  EXCHANGE = /x(\d+)\/(\d+)/
  PARTNER = /p(\w+)\/(\w+)/

  module_function

  def party(dance_line, moves, turns = 1)
    (moves * turns).inject(dance_line) { |line, move| apply(line, move) }
  end

  def party2(dance_line, moves, turns = 1)
    partner_moves, spin_exchange_moves = moves.partition { |move| is_partner?(move) }
    single_spin_exchange_transformation = spin_exchange_moves.inject(dance_line) { |line, move|
      apply(line, move)
    }.map { |c|
      dance_line.index(c)
    }
    cycle = catch(:cycle) {
      full_spin_exchange_transformation = nil
      2.upto(turns).detect { |i|
        full_spin_exchange_transformation = i.times.inject((0...dance_line.size).to_a) { |m,_|
          single_spin_exchange_transformation.map { |c| m[c] }
        }
        throw :cycle, i - 1 if full_spin_exchange_transformation == single_spin_exchange_transformation
      }
      throw :cycle
    } || turns + 1
    full_spin_exchange_transformation = (turns % cycle).times.inject((0...dance_line.size).to_a) { |m,_|
      single_spin_exchange_transformation.map { |c| m[c] }
    }
    dance_line_after_spins_and_exchanges = full_spin_exchange_transformation.map { |c| dance_line[c] }
    (partner_moves * turns).inject(dance_line_after_spins_and_exchanges) { |line, move|
      apply(line, move)
    }
  end

  def apply(line, move)
    if (md = SPIN.match(move))
      line.rotate(-(md[1].to_i))
    elsif (md = EXCHANGE.match(move))
      p1, p2 = md.captures.map(&:to_i)
      line.dup.tap { |_line| _line[p1], _line[p2] = _line[p2], _line[p1] }
    elsif (md = PARTNER.match(move))
      p1, p2 = md.captures.map { |name| line.index(name) }
      line.dup.tap { |_line| _line[p1], _line[p2] = _line[p2], _line[p1] }
    else
      raise ArgumentError, "Unknown move: #{move}"
    end
  end

  def is_partner?(move)
    move =~ PARTNER
  end
end

if $0 == __FILE__
  if ARGV.empty?
    puts "Usage: #{$0} turns_around_the_floor moves_file"
    exit 1
  end

  turns_around_the_floor = ARGV.shift.to_i
  dance_line = (?a..?p).to_a
  moves = ARGF.read.chomp.split(',')
  dance_line = Dance.party(dance_line, moves)
  puts "After 1: #{dance_line.join}"
  (turns_around_the_floor - 1).times { dance_line = Dance.party(dance_line, moves) }
  puts "After #{turns_around_the_floor}: #{dance_line.join}"
end
