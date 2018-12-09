class Node
  attr_reader :nodes, :metadata

  def self.parse(tokens)
    Node.new.tap do |node|
      node_count = tokens.shift
      metadata_count = tokens.shift
      node_count.times do
        node.nodes << Node.parse(tokens)
      end
      metadata_count.times do
        node.metadata << tokens.shift
      end
    end
  end

  def initialize(nodes: [], metadata: [])
    @nodes = nodes
    @metadata = Array(metadata)
  end

  def metadata_sum
    nodes.sum(&:metadata_sum) + metadata.sum
  end

  def value
    if nodes.empty?
      metadata.sum
    else
      metadata.map { |index| nodes[index - 1]&.value || 0 }.sum
    end
  end
end

tokens = ARGF.read.chomp.scan(/\d+/).map(&:to_i)
root = Node.parse(tokens)
puts "Part 1: #{root.metadata_sum}"
puts "Part 2: #{root.value}"
