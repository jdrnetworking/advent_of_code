#!/usr/bin/env ruby

def parse(input)
  re = /(.*) \(contains (.*)\)/
  input.split(/\n/).map { |line|
    ingredient_list, allergen_list = line.match(re).captures
    [ingredient_list.split(' '), allergen_list.split(', ')]
  }
end

if $0 == __FILE__
  all_the_things = parse(ARGF.read)
  possibilities = all_the_things.each_with_object({}) { |(ingredients, allergens), o|
    allergens.each do |allergen|
      if o.key?(allergen)
        o[allergen] = o[allergen] & ingredients
      else
        o[allergen] = ingredients
      end
    end
  }
  all_ingredients = all_the_things.flat_map(&:first)
  puts (all_ingredients - possibilities.values.flatten).size

  queue = possibilities.select { |k,v| v.size == 1 }.keys
  while (allergen = queue.shift) do
    possibilities.select { |_,v| v.size > 1 && v.include?(possibilities[allergen].first) }.keys.each do |k|
      possibilities[k] -= possibilities[allergen]
      queue.push(k) if possibilities[k].size == 1
    end
  end
  puts possibilities.to_a.sort_by(&:first).map(&:last).map(&:first).join(',')
end
