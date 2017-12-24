#!/usr/bin/env ruby

class Particle
  attr_accessor :name, :position, :velocity, :acceleration

  def initialize(name, position, velocity, acceleration)
    @name = name
    @position = position
    @velocity = velocity
    @acceleration = acceleration
  end

  def distance
    manhattan(position)
  end

  def manhattan(components)
    components.map(&:abs).sum
  end

  def move
    self.velocity = velocity.zip(acceleration).map(&:sum)
    self.position = position.zip(velocity).map(&:sum)
  end

  def self.parse(name, line)
    if (md = /p=<(?<position>\s*-?\d+,\s*-?\d+,\s*-?\d+)>, v=<(?<velocity>\s*-?\d+,\s*-?\d+,\s*-?\d+)>, a=<(?<acceleration>\s*-?\d+,\s*-?\d+,\s*-?\d+)>/.match(line))
      new(name, md[:position].split(?,).map(&:to_i), md[:velocity].split(?,).map(&:to_i), md[:acceleration].split(?,).map(&:to_i))
    end
  end
end

class Swarm
  attr_accessor :particles

  def initialize(particles)
    @particles = particles
  end

  def size
    particles.size
  end

  def chicken_dinner
    particles.sort_by { |p|
      [p.manhattan(p.acceleration), p.manhattan(p.velocity), p.manhattan(p.position)]
    }.first
  end

  def step
    particles.each(&:move)
    remove_collisions
    size
  end

  def remove_collisions
    particles.group_by(&:position).each do |position, grouped|
      grouped.each { |p| particles.delete(p) } if grouped.size > 1
    end
  end

  def find_stable_size(threshold = 10)
    swarm_sizes = []
    loop do
      step
      swarm_sizes << size
      break if swarm_sizes.size >= threshold && swarm_sizes.last(threshold).uniq.size == 1
    end
    swarm_sizes.last
  end

  def self.parse(lines)
    new(lines.map.with_index { |line,index| Particle.parse(index, line) })
  end
end

if $0 == __FILE__
  swarm = Swarm.parse(ARGF.readlines.map(&:chomp))
  puts "Winner, winner: #{swarm.chicken_dinner.name}"
  puts "Stable size: #{swarm.find_stable_size}"
end
