input = STDIN.readlines.join(", ").chomp
changes = input.scan(/[+-]\d+/).map(&:to_i)

# Part 1
puts "Sum: #{changes.sum}"

# Part 2
current = 0
frequencies = Hash.new(0)
frequencies[current] += 1
loop do
  changes.each do |change|
    current += change
    if frequencies.include?(current)
      puts "Seen twice: #{current}"
      exit
    else
      frequencies[current] += 1
    end
  end
end
