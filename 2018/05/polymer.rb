
input = STDIN.gets.chomp

def react(input)
  polymer = input.dup
  until (matches = polymer.bytes.each_cons(2).with_index.select { |(a,b),index| (a-b).abs == 32 }.map(&:last)).empty? do
    matches.reverse_each do |match|
      polymer[match,2] = '' if match < polymer.size - 1 && (polymer.bytes[match]-polymer.bytes[match+1]).abs == 32
    end
  end
  polymer
end
puts "Part 1: #{react(input).size}"

all_characters = input.downcase.chars.uniq
min_length = all_characters.map { |char| react(input.delete("#{char}#{char.upcase}")).size }.min
puts "Part 2: #{min_length}"
