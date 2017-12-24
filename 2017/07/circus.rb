#!/usr/bin/env ruby

module Circus
  module Builder
    NODE_STRING = /\A(?<name>\w+) \((?<weight>\d+)\)( -> (?<child_names>(\w+, )*(\w+)))?\z/

    module_function

    def build_tree(node_strings)
      pool = node_strings.each_with_object({}) do |node_string, pool|
        name, attributes = parse_node_string(node_string)
        pool[name] = attributes
      end

      pool.each do |name, attributes|
        next if attributes[:child_names].empty?
        pool[name] = build_node(pool, name)
      end

      pool.values.first
    end

    def build_node(pool, name)
      attributes = pool[name]
      node = Node.new(name, weight: Integer(attributes[:weight]))
      attributes[:child_names].each do |child_name|
        unless pool.fetch(child_name).is_a?(Node)
          pool[child_name] = build_node(pool, child_name)
        end
        node.add_child(pool.delete(child_name))
      end
      pool[name] = node
    end

    def parse_node_string(node_string)
      raise InvalidNodeStringFormat unless (match_data = NODE_STRING.match(node_string))
      child_names = match_data[:child_names].to_s.split(', ')
      [match_data[:name], { weight: match_data[:weight], child_names: child_names }]
    end

    class InvalidNodeStringFormat < ArgumentError; end
  end

  class Node
    attr_accessor :name, :weight, :parent, :children

    def initialize(name, weight: 0, children: [])
      @name = name
      @weight = weight
      @parent = nil
      @children = children
    end

    def add_child(child_node)
      raise AdoptionError, "#{child_node.name} is already a child of #{child_node.parent.name}" if child_node.parent
      child_node.parent = self
      children << child_node
    end

    def total_weight
      weight + children.sum(&:total_weight)
    end

    def imbalanced?
      children.map(&:total_weight).uniq.size > 1
    end

    def [](_name)
      children.detect { |child| child.name == _name }
    end

    def find(search_name)
      search_name == name ? self : children.flat_map { |child| child.find(search_name) }.compact.first
    end

    def to_s
      "#{name} (#{total_weight})" +
        (" #{weight} + (#{children.map(&:total_weight).join(' ')}) #{imbalanced? ? '𝘅' : '✔'}" unless children.empty?).to_s
    end

    def inspect
      to_s
    end

    def pp(indent = 0)
      children_pp = children.map { |child| child.pp(indent + 1) }.join
      ("  " * indent) + to_s + "\n" + children_pp
    end
  end
end

if $0 == __FILE__
  node_strings = ARGF.readlines.map(&:chomp)
  root = Circus::Builder.build_tree(node_strings)
  puts root.pp
end
