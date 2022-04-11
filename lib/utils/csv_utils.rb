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
    columns_counts = CSV.read(filename, col_sep: separator)[1..-1].map(&:compact).map(&:size).uniq
    columns_counts.size == 1 && columns_counts.first > 1
  rescue CSV::MalformedCSVError
    false
  end
end
