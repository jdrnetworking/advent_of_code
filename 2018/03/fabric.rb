CLAIM = /#(?<id>\d+) @ (?<x>\d+),(?<y>\d+): (?<w>\d+)x(?<h>\d+)/
HEADERS = [:id, :x, :y, :width, :height]

# Part 1
def print_fabric(fabric)
  fabric.size.downto(1) do |y|
    puts fabric[y-1].join(' ')
  end
  puts
end

claims = STDIN.readlines.join(' ').scan(CLAIM).map { |values| HEADERS.zip(values.map(&:to_i)).to_h }
fabric_height = claims.map { |claim| claim[:y] + claim[:height] }.max
fabric_width = claims.map { |claim| claim[:x] + claim[:width] }.max
fabric = Array.new(fabric_height) { Array.new(fabric_width, 0) }

claims.each do |claim|
  (claim[:y]...(claim[:y] + claim[:height])).each do |y|
    (claim[:x]...(claim[:x] + claim[:width])).each do |x|
      fabric[y][x] += 1
    end
  end
end
puts "Conflict area: #{fabric.map { |row| row.count { |cell| cell > 1 } }.sum}"

# Part 2
chosen_one = claims.detect do |claim|
  (claim[:y]...(claim[:y] + claim[:height])).all? do |y|
    (claim[:x]...(claim[:x] + claim[:width])).all? do |x|
      fabric[y][x] == 1
    end
  end
end
puts "Chosen one: #{chosen_one[:id]}"
