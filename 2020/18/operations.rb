#!/usr/bin/env ruby

def tokenize(input)
  input.scan(/\d+|[+*()=]/).map { |m| m =~ /\A\d+\z/ ? m.to_i : m }
end

def perform(a, op, b)
  case op
  when '+', '*' then a.send(op, b)
  when '=' then a == b
  else raise ArgumentError, op
  end
end

def evaluate_basic(tokens)
  tokens[0,3] = perform(*tokens[0,3]) until tokens.size == 1
  tokens
end

def reduce_basic(tokens)
  opens = []
  i = 0
  loop do
    if tokens[i] == '('
      opens.push(i)
    elsif tokens[i] == ')'
      tokens[opens.last..i] = evaluate_basic(tokens[(opens.last + 1)..(i - 1)])
      i = opens.pop
    end
    i += 1
    break if i >= tokens.size
  end
  evaluate_basic(tokens) until tokens.size == 1
  tokens.first
end

def evaluate_advanced(tokens)
  while (i = tokens.index('+')) do
    tokens[i-1, 3] = perform(*tokens[i-1, 3])
  end
  tokens[0, 3] = perform(*tokens[0, 3]) until tokens.size == 1
  tokens
end

def reduce_advanced(tokens)
  opens = []
  i = 0
  loop do
    if tokens[i] == '('
      opens.push(i)
    elsif tokens[i] == ')'
      tokens[opens.last..i] = evaluate_advanced(tokens[(opens.last + 1)..(i - 1)])
      i = opens.pop
    end
    i += 1
    break if i >= tokens.size
  end
  evaluate_advanced(tokens) until tokens.size == 1
  tokens.first
end

if $0 == __FILE__
  lines = ARGF.readlines.map(&:chomp)
  answers = lines.map { |line| tokens = tokenize(line); reduce_basic(tokens) }
  puts "Part 1\n------"
  if lines.size < 20
    puts lines.zip(answers).map { |line, answer| "#{line} = #{answer}" }
  else
    puts "Sum of answers: #{answers.sum}"
  end

  puts "\nPart 2\n------"
  answers = lines.map { |line| tokens = tokenize(line); reduce_advanced(tokens) }
  if lines.size < 20
    puts lines.zip(answers).map { |line, answer| "#{line} = #{answer}" }
  else
    puts "Sum of answers: #{answers.sum}"
  end
end
