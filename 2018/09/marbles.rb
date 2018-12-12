class RingBuffer
  attr_reader :buffer
  attr_accessor :current

  def initialize(*elements)
    @buffer = elements.dup
    @current = 0 unless buffer.empty?
  end

  def [](index)
    buffer[(current + index) % buffer.size]
  end

  def []=(index, value)
    target_index = ((current + index - 1) % buffer.size) + 1
    buffer.insert(target_index, value)
    self.current = target_index
  end

  def delete_at(index)
    target_index = (current + index) % buffer.size
    self.current = target_index % (buffer.size - 1)
    buffer.delete_at(target_index)
  end

  def to_s
    return '' if buffer.empty?

    field_width = Math.log10(buffer.size).floor + 1
    (
      buffer.take(current).map { |elem| " %#{field_width}d" % elem }.join +
      "(#{buffer[current]})" +
      buffer.drop(current + 1).map { |elem| "%#{field_width}d " % elem }.join
    ).strip
  end
end

if $0 == __FILE__
  players = ARGV[0].to_i
  marbles = ARGV[1].to_i
  current_player = 1
  last_marble_worth = 0

  scores = Array.new(players, 0)
  b = RingBuffer.new(0)
  1.upto(marbles) do |marble|
    if (marble % 23).zero?
      last_marble_worth = marble + b.delete_at(-7)
      scores[current_player - 1] += last_marble_worth
    else
      b[2] = marble
    end
    current_player = (current_player % players) + 1
  end
  puts "High score #{scores.max}"
  puts "Last marble worth #{last_marble_worth}"
end
