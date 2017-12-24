#!/usr/bin/env ruby

class Group
  attr_accessor :children, :parent

  def initialize(parent: nil)
    @children = []
    @parent = parent
    parent.children << self if parent
  end

  def score
    parent ? parent.score + 1 : 1
  end

  def total_score
    score + children.sum(&:total_score)
  end

  def group_count
    1 + children.sum(&:group_count)
  end

  def count
    1 + children.sum(&:count)
  end
end

module Processor
  module_function

  def process_stream(input)
    current = nil
    root = nil
    garbage_character_count = 0
    stream = StringIO.new(input)
    while (c = stream.getc)
      case c
      when '{'
        current = Group.new(parent: current)
        root = current if current.parent.nil?
      when '}'
        current = current.parent
      when '<'
        until ((c = stream.getc) == '>')
          if c == '!'
            stream.getc
          else
            garbage_character_count += 1
          end
        end
      end
    end
    [root, garbage_character_count]
  end

  def summarize(stream)
    if stream.nil?
      'nil'
    elsif stream.length > 50
      stream[0,25] + '...' + stream[-22,22]
    else
      stream
    end
  end
end

if $0 == __FILE__
  ARGF.each_line do |stream|
    stream.chomp!
    group, garbage_character_count = Processor.process_stream(stream)
    puts "#{Processor.summarize(stream)}: #{group.group_count} groups, total score: #{group.total_score}, garbage cleaned: #{garbage_character_count}"
  end
end
