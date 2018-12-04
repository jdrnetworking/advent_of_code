ON_SHIFT_RE = /Guard #(?<id>\d+) begins shift/
SLEEP_RE = /:(?<min>\d{2})\] falls asleep/
WAKE_RE = /:(?<min>\d{2})\] wakes up/

input = STDIN.readlines.map(&:chomp)
sleepytime = Hash.new { |h,k| h[k] = Array.new(60, 0) }
current_guard = nil
asleep_at = nil
input.sort.each do |log_entry|
  case log_entry
  when ON_SHIFT_RE
    current_guard = log_entry[ON_SHIFT_RE, :id].to_i
  when SLEEP_RE
    asleep_at = log_entry[SLEEP_RE, :min].to_i
  when WAKE_RE
    raise ArgumentError, "Unknown guard!" unless current_guard
    raise ArgumentError, "Guard #{current_guard} not asleep but is waking up!" unless asleep_at
    awake_at = log_entry[WAKE_RE, :min].to_i
    (asleep_at...awake_at).each do |min|
      sleepytime[current_guard] ||= Array.new(60, 0)
      sleepytime[current_guard][min] += 1
    end
  else
    raise ArgumentError, "Unexpected input: '#{log_entry}'"
  end
end

sleepiest_guard = sleepytime.transform_values(&:sum).max_by(&:last).first
sleepiest_minute = sleepytime[sleepiest_guard].index(sleepytime[sleepiest_guard].max)
puts "Part 1: #{sleepiest_guard * sleepiest_minute}"

sleepiest_guard_2 = sleepytime.map { |id, minutes| [id, minutes.max] }.max_by(&:last).first
sleepiest_minute_2 = sleepytime[sleepiest_guard_2].index(sleepytime[sleepiest_guard_2].max)
puts "Part 2: #{sleepiest_guard_2 * sleepiest_minute_2}"
