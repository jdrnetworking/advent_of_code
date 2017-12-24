#!/usr/bin/env ruby

class PassphraseValidator
  def valid?(passphrase)
    passphrase_words = words(passphrase)
    passphrase_words.size > 1 && passphrase_words.size == passphrase_words.uniq.size
  end

  def validate_inputs(inputs)
    results = inputs.partition { |input| valid?(input) }
    { valid: results.first.size, invalid: results.last.size }
  end

  private

  def words(passphrase)
    passphrase.to_s.split(/\s+/)
  end
end

class PassphraseValidator2 < PassphraseValidator
  def valid?(passphrase)
    passphrase_words = words(passphrase)
    passphrase_words.size > 1 &&
      passphrase_words.size == passphrase_words.uniq.size &&
      anagrams(passphrase_words).empty?
  end

  private

  def anagrams(words)
    words.select { |word|
      (words - [word]).any? { |other_word|
        other_word.chars.sort == word.chars.sort
      }
    }
  end
end

if $0 == __FILE__
  inputs = STDIN.read.chomp.split(/[\r\n]+/)
  puts PassphraseValidator.new.validate_inputs(inputs).inspect
  puts PassphraseValidator2.new.validate_inputs(inputs).inspect
end
