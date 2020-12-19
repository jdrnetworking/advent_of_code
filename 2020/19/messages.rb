#!/usr/bin/env ruby

def parse(input)
  rule_input, message_input = input.split(/\n\n/)
  rules = rule_input.split(/\n/).map { |line| line.split(': ') }.to_h
  messages = message_input.split(/\n/)
  [sanitize_rules(rules), messages]
end

def sanitize_rules(rules)
  rules.each_with_object({}) { |(k,v),o|
    o[k] = case v
           when /"(.*)"/ then v.delete('"')
           when /\|/ then "(?:#{v})"
           else v
           end
  }
end

def resolve(pattern, rules)
  last, cur = nil, pattern
  until last == cur do
    last = cur
    cur = cur.gsub(/\b\d+\b/) { |ref|
      rules[ref]
    }
  end
  Regexp.new("^#{cur}$", Regexp::EXTENDED)
end

def modify(rules)
  rules.dup.tap { |r|
    r['8'] = "(?<r8>42 | 42 \\\g<r8>)"
    r['11'] = "(?<r11>42 31 | 42 \\\g<r11> 31)"
  }
end

if $0 == __FILE__
  rules, messages = parse(ARGF.read)
  regexp1 = resolve(rules['0'], rules)
  regexp2 = resolve(rules['0'], modify(rules))

  match_counts = [0, 0]
  messages.each do |message|
    match_counts[0] += 1 if (match1 = regexp1.match?(message))
    match_counts[1] += 1 if (match2 = regexp2.match?(message))
    puts "#{match1 ? '🟢' : '🔴'} #{match2 ? '🟢' : '🔴'} #{message}"
  end
  puts ['Match 1: ', 'Match 2: '].zip(match_counts).map(&:join)
end
