require 'pry-byebug'

EXPR_RE = /Step ([A-Z]) must be finished before step ([A-Z]) can begin./

steps = ARGF.readlines.map { |step| EXPR_RE.match(step).captures }

sequence = ''

def build_graph(steps)
  graph = steps.flatten.uniq.each_with_object({}) { |step,g| g[step] = [] }
  steps.each do |prereq, step|
    graph[step] << prereq
  end
  graph
end

def next_available_steps(graph)
  graph.select { |step, prereqs| prereqs.empty? }.keys.sort
end

def perform_step(graph, step)
  graph.delete(step)
  graph.values.each { |prereqs| prereqs.delete(step) }
end

graph = build_graph(steps)
until (ns = next_available_steps(graph)).empty? do
  step = ns.first
  sequence << step
  perform_step(graph, step)
end
puts "Part 1: #{sequence}"
