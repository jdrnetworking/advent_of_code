#!/usr/bin/env ruby

class System
  attr_reader :moons

  def initialize(moons)
    @moons = moons.map(&:dup)
  end

  def step!(n = 1)
    n.times do
      moons.combination(2).each do |m1,m2|
        m1.apply_gravity!(m2)
        m2.apply_gravity!(m1)
      end
      moons.each(&:update_position!)
    end
  end

  def total_energy
    moons.sum(&:total_energy)
  end

  def inspect
    moons.map(&:inspect).join("\n")
  end

  def x_state
    moons.inject([]) { |s,v| s + [v.px, v.vx] }
  end

  def y_state
    moons.inject([]) { |s,v| s + [v.py, v.vy] }
  end

  def z_state
    moons.inject([]) { |s,v| s + [v.pz, v.vz] }
  end
end

class Moon
  INPUT_RE = /<x=(?<x>-?\d+), y=(?<y>-?\d+), z=(?<z>-?\d+)>/

  attr_accessor :px, :py, :pz, :vx, :vy, :vz

  def initialize(x, y, z)
    @px, @py, @pz = x, y, z
    @vx, @vy, @vz = 0, 0, 0
  end

  def total_energy
    potential_energy * kinetic_energy
  end

  def potential_energy
    px.abs + py.abs + pz.abs
  end

  def kinetic_energy
    vx.abs + vy.abs + vz.abs
  end

  def apply_gravity!(other)
    self.vx += other.px <=> self.px
    self.vy += other.py <=> self.py
    self.vz += other.pz <=> self.pz
  end

  def update_position!
    self.px += vx
    self.py += vy
    self.pz += vz
  end

  def inspect
    "p <#{px}, #{py}, #{pz}>, v <#{vx}, #{vy}, #{vz}>"
  end

  def self.parse(input)
    if (md = INPUT_RE.match(input))
      new(*md.captures.map(&:to_i))
    end
  end
end

class PeriodFinder
  attr_reader :s1, :s2

  def initialize(moons)
    @s1 = System.new(moons)
    @s2 = System.new(moons)
  end

  def period
    i = 0
    period_x, period_y, period_z = nil, nil, nil
    loop do
      s1.step!
      s2.step!(2)
      i += 1
      period_x = i if period_x.nil? && s1.x_state == s2.x_state
      period_y = i if period_y.nil? && s1.y_state == s2.y_state
      period_z = i if period_z.nil? && s1.z_state == s2.z_state
      break if period_x && period_y && period_z
    end
    period_x.lcm(period_y).lcm(period_z)
  end
end

if $0 == __FILE__
  lines = ARGF.readlines.map(&:strip)
  steps = 1
  expected1, expected2 = nil, nil
  moons = []
  lines.each do |line|
    if line =~ Moon::INPUT_RE
      moons << Moon.parse(line)
    else
      steps, expected1, expected2 = line.split(',').map(&:to_i)
    end
  end
  system = System.new(moons)
  system.step!(steps)
  total_energy = system.total_energy
  period_finder = PeriodFinder.new(moons)
  period = period_finder.period

  if expected1
    puts "Part 1: Expected #{expected1}, got #{total_energy} #{total_energy == expected1 ? '✅' : '🛑'}"
    if expected2
      puts "Part 2: Expected #{expected2}, got #{period} #{period == expected2 ? '✅' : '🛑'}"
    end
  else
    puts "Part 1: #{total_energy}"
    puts "Part 2: #{period}"
  end
end
