module BIOS
  module_function

  def assert_or_print(expected, actual, label: nil)
    label = label + ': ' if label
    if expected
      puts "#{label}Expected #{expected}, got #{actual} #{expected == actual ? '✅' : 'x'}"
    else
      puts "#{label}#{actual}"
    end
  end
end
