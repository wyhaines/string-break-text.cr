require "./version"

class String
  # This is a helper function for nicely formatting strings with natural-appearing
  # line wrapping. It takes a string and breaks it into lines of a maximum length,
  # inserting newlines where necessary. It also attempts to break lines at word
  # boundaries, and to avoid breaking lines in the middle of words. It does this
  # by calculating the average word length and standard deviation of word length,
  # and using these to determine the maximum word length to allow before breaking.

  # Words that are longer than the maximum word length (i.e. a word length that is
  # larger than typical, and which would thus cause the text appearance to be
  # peculiar, with a large end-of-line gap) are broken at a point that is
  # generally 20% - 80% of the way through the word using a hyphen. The algorithm
  # also refuses to break a word that starts with a non-letter character, to avoid
  # breaking things like directory paths.

  # Finally, the algorithm maintains the indetation at the start of a line, when a
  # line is broken into multiple lines. This maintains text formatting, for
  # complex text, such as help text or documents with examples.
  #
  # ameba:disable Metrics/CyclomaticComplexity
  def wrap(max_line_length : Int32 = 80, hyphenate = true) : String
    return self if max_line_length <= 0

    max_word_length = calculate_max_word_length(max_line_length)
    lines = [] of String
    line = ""
    word = ""
    indentation = ""
    has_determined_indentation = false

    self.chars.each_with_index do |char, position|
      word += char

      if char.whitespace? || position == self.size - 1
        if char != '\n' && !has_determined_indentation
          indentation += char
        end
        if line.size + word.size < max_line_length
          line += word
          word = ""
        else
          while line.size + word.size >= max_line_length
            line, word = break_line(lines, line, word, max_line_length, max_word_length, indentation, hyphenate, position >= self.size - 1)
          end
        end
        if char == '\n'
          lines << line
          line = ""
          indentation = ""
          has_determined_indentation = false
        else
          if line.size >= max_line_length || position == self.size - 1
            lines << line
            line = ""
          end
        end
      else
        has_determined_indentation = true
      end
      lines.join
    end
    # while line.size + word.size >= max_line_length
    #   line, word = break_line(lines, line, word, max_line_length, max_word_length, indentation, hyphenate, position >= self.size - 1)
    # end
    lines << line unless line.empty?
    lines.join
  end

  private def calculate_max_word_length(max_line_length)
    # Split the string into words to calculate word length statistics
    words = self.split(' ')
    word_lengths = words.map(&.size)

    # Calculate average word length
    average = word_lengths.sum.to_f / word_lengths.size

    # Calculate standard deviation of word length
    sum_of_squared_differences = word_lengths.reduce(0.0) { |sum, length| sum + (length - average)**2 }
    standard_deviation = Math.sqrt(sum_of_squared_differences / word_lengths.size)

    # Determine the maximum word length to allow before breaking
    [max_line_length, average + standard_deviation].min
  end

  private def break_line(lines, line, word, max_line_length, max_word_length, indentation, hyphenate = true, end_of_string = false)
    if line.size + word.size > max_line_length && word.size > max_word_length
      first_character = word[0]
      minsplit, maxsplit = calculate_min_and_max_splits(word)
      middle = max_line_length - line.size - 1
      if hyphenate && first_character.upcase != first_character.downcase && word.size > max_word_length && middle > minsplit && middle < maxsplit
        part = word[0...middle]
        remaining = word[middle..]
        lines << "#{line}#{part}#{remaining.size > 0 ? "-" : ""}"
        line = indentation + remaining
      else
        lines << line.rstrip(' ')
        line = indentation + word
      end
    else
      lines << line.rstrip(' ')
      line = indentation + word
    end
    word = ""
    add_newline_if_needed(lines, line, end_of_string)

    {line, word}
  end

  private def add_newline_if_needed(lines, line, end_of_string)
    if !line.empty? || !end_of_string
      lines << "\n"
    end
  end

  private def calculate_min_and_max_splits(word)
    [
      [2, (word.size * 0.2).floor].max,
      [word.size - 3, (word.size * 0.8).ceil].max,
    ]
  end
end
