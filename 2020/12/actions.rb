#!/usr/bin/env ruby

def parse(input)
  input.split(/\r?\n/).map { |line|
    /^(\w)(\d+)$/.match(line).captures.tap { |c| c[1] = c[1].to_i }
  }
end

def next_state(state, action)
  direction, qty = action
  case direction
  when /[NSEW]/ then move(state, direction, qty)
  when /[LR]/ then turn(state, direction, qty)
  when 'F' then move(state, state[:direction], qty)
  end
end

def move(state, direction, qty)
  x, y = translate_movement(direction, qty)
  state.merge({
    x: state[:x] + x,
    y: state[:y] + y,
  })
end

def turn(state, direction, qty)
  directions = %w[N E S W]
  new_direction = directions[(directions.index(state[:direction]) + (direction == 'R' ? 1 : -1) * (qty / 90)) % directions.size]
  state.merge({ direction: new_direction })
end

def translate_movement(direction, qty)
  case direction
  when 'N' then [0, qty]
  when 'S' then [0, -qty]
  when 'E' then [qty, 0]
  when 'W' then [-qty, 0]
  end
end

def next_state2(state, action)
  direction, qty = action
  case direction
  when /[NSEW]/ then move_waypoint(state, direction, qty)
  when /[LR]/ then rotate_waypoint(state, direction, qty)
  when 'F' then move_to_waypoint(state, qty)
  end
end

def move_waypoint(state, direction, qty)
  x, y = translate_movement(direction, qty)
  state.merge({
    wx: state[:wx] + x,
    wy: state[:wy] + y,
  })
end

def move_to_waypoint(state, qty)
  state.merge({
    x: state[:x] + qty * state[:wx],
    y: state[:y] + qty * state[:wy],
  })
end

def rotate_waypoint(state, direction, qty)
  state.merge(translate_rotation(state[:wx], state[:wy], direction, qty))
end

def translate_rotation(wx, wy, direction, qty)
  if direction == 'L'
    direction = 'R'
    qty = 360 - qty
  end
  case qty
  when 90 then { wx: wy, wy: -wx }
  when 180 then { wx: -wx, wy: -wy }
  when 270 then { wx: -wy, wy: wx }
  end
end

def initial_state
  {
    direction: 'E',
    x: 0,
    y: 0,
    wx: 10,
    wy: 1,
  }
end

def manhattan_distance(x, y)
  x.abs + y.abs
end

if $0 == __FILE__
  actions = parse(ARGF.read)

  final_state = actions.reduce(initial_state) { |state, action| next_state(state, action) }
  puts manhattan_distance(final_state[:x], final_state[:y])

  final_state = actions.reduce(initial_state) { |state, action| next_state2(state, action) }
  puts manhattan_distance(final_state[:x], final_state[:y])
end
