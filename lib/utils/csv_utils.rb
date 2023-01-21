# frozen_string_literal: true

class CsvUtils
  def self.detect_separator(filename)
    %w( , ; ).each do |separator|
      return separator if separator_check(filename, separator)
    end

    raise "No separator found for #{filename}"
  end

  def self.separator_check(filename, separator)
    # Skip the first line just in case it contains a header
    # Does a compact, to remove empty cells
    data = columns_counts = CSV.read(filename, col_sep: separator)[1..-1].map(&:compact)
    first_row_size = data.first.size
    data.all? { |row| row.size == first_row_size }
  rescue CSV::MalformedCSVError
    false
  end
end
