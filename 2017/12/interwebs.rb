#!/usr/bin/env ruby

class Neighborhood
  BLUEPRINT_LINE = /(?<subject>\w+) <-> (?<neighbors>(\w+, )*\w+)/

  attr_accessor :neighbors

  def initialize(blueprint)
    @neighbors = blueprint.keys.each_with_object({}) { |name, o|
      o[name] = Neighbor.new(name)
    }
    blueprint.each do |name, neighbor_names|
      neighbor_names.each do |neighbor_name|
        neighbors[name].add_neighbor(neighbors[neighbor_name])
      end
    end
  end

  def [](name)
    neighbors[name]
  end

  def to_s
    "[#{neighbors.map(&:name).join(', ')}]"
  end

  def inspect
    to_s
  end

  def groups
    neighbors.values.map(&:group).uniq
  end

  def self.parse_blueprint(input)
    input.scan(BLUEPRINT_LINE).each_with_object({}) { |(subject, neighbors), blueprint|
      blueprint[subject] = neighbors.split(/,\s*/)
    }
  end

  def self.from_blueprint(input)
    new(parse_blueprint(input))
  end
end

class Neighbor
  attr_accessor :name, :neighbors

  def initialize(name)
    @name = name
    @neighbors = []
  end

  def to_s
    "#{name}: #{neighbors.map(&:name).join(', ')}"
  end

  def inspect
    to_s
  end

  def add_neighbor(neighbor)
    neighbors << neighbor unless neighbors.include?(neighbor)
  end

  def group(except: [])
    ([name] + (neighbors - except).flat_map { |neighbor|
      neighbor.group(except: except + [self])
    }).uniq.sort
  end
end

if $0 == __FILE__
  neighborhood = Neighborhood.from_blueprint(ARGF.read)
  puts "Group size (0): #{neighborhood['0'].group.size}"
  puts "Groups in neighborhood: #{neighborhood.groups.size}"
end
