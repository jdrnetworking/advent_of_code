box_ids = STDIN.readlines.map(&:chomp)

# Part 1
counts = box_ids.each_with_object(Hash.new(0)) do |box_id, counts|
  char_counts = box_id.chars.group_by(&:itself).transform_values(&:count).select { |char,count| [2,3].include?(count) }.invert
  char_counts.keys.each do |count|
    counts[count] += 1
  end
end
puts counts[2] * counts[3]

# Part 2
def differ_by_1?(str1, str2)
  _diff = diff(str1, str2)
  _diff.size - _diff.count(&:zero?) == 1
end

def diff(str1, str2)
  str1.bytes.zip(str2.bytes).map { |a,b| a - b }
end

pair = catch(:pair) {
  box_ids.each_with_index do |box_id_1, i|
    box_ids.drop(i).each do |box_id_2|
      throw :pair, [box_id_1, box_id_2] if differ_by_1?(box_id_1, box_id_2)
    end
  end
}
_diff = diff(*pair)
tag = pair.first.chars.select.with_index { |_, index| _diff[index].zero? }.join
puts tag
