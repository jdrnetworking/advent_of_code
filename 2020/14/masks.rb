#!/usr/bin/env ruby

def mask_re
  /mask = (?<mask>[10X]+)/
end

def assignment_re
  /mem\[(?<address>\d+)\] = (?<value>\d+)/
end

def execute(instruction, state, version: 1)
  if (md = mask_re.match(instruction))
    state.merge(mask: md[:mask])
  elsif version == 1 && (md = assignment_re.match(instruction))
    state.merge(memory: assign_v1(state, md[:address].to_i, md[:value].to_i))
  elsif version == 2 && (md = assignment_re.match(instruction))
    state.merge(memory: assign_v2(state, md[:address].to_i, md[:value].to_i))
  else
    raise ArgumentError, "Unknown instruction: #{instruction}"
  end
end

def assign_v1(state, address, value)
  or_mask = state[:mask].tr('X', '0').to_i(2)
  and_mask = state[:mask].tr('X', '1').to_i(2)
  effective_value = value & and_mask | or_mask
  state[:memory].merge(address => effective_value)
end

def assign_v2(state, address, value)
  effective_addresses(state[:mask], address).reduce(state[:memory]) { |memory, effective_address|
    memory.merge(effective_address => value)
  }
end

def effective_addresses(mask, address)
  or_mask = mask.tr('X', '0').to_i(2)
  effective_address = (address | or_mask).to_s(2).rjust(mask.size, '0')
  [0, 1].repeated_permutation(mask.count('X')).map { |bits|
    bits.reduce([effective_address, 0]) { |(ea, start_pos), bit|
      x_loc = mask.index('X', start_pos)
      ea[x_loc] = bit.to_s
      [ea, x_loc + 1]
    }.first.to_i(2)
  }
end

def initial_state
  {
    memory: Hash.new { |h,k| h[k] = 0 },
    mask: nil,
  }
end

if $0 == __FILE__
  instructions = ARGF.each_line.to_a

  state = instructions.reduce(initial_state) { |state, instruction| execute(instruction, state) }
  puts state[:memory].values.inject(:+)

  state = instructions.reduce(initial_state) { |state, instruction| execute(instruction, state, version: 2) }
  puts state[:memory].values.inject(:+)
end
