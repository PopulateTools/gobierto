# frozen_string_literal: true

class CsvUtils
  CANDIDATE_SEPARATORS = %w(, ;).freeze

  def self.detect_separator(filename)
    CANDIDATE_SEPARATORS.each do |separator|
      return separator if separator_check(filename, separator)
    end

    raise "No separator found for #{filename}"
  end

  def self.separator_check(filename, separator)
    rows = read_rows(filename, separator)
    return false if rows.blank?

    first_row_size = rows[0].size

    maybe_header = rows[0].all?(&:present?)

    rows[1..-1].all? do |row|
      # If a header is detected all the rows with all columns present should
      # have the same size
      if maybe_header && row.all?(&:present?)
        row.size == first_row_size
      else
        row.size <= first_row_size
      end
    end
  end

  def self.read_rows(filename, separator)
    CSV.read(filename, col_sep: separator)
  rescue CSV::MalformedCSVError
    []
  end
end
