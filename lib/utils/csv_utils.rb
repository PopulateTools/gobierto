# frozen_string_literal: true

module Utils
  class CsvUtils
    def self.detect_separator(filename)
      %w( , ; ).each do |separator|
        return separator if separator_check(filename, separator)
      end

      raise "No separator found for #{filename}"
    end

    def self.separator_check(filename, separator)
      columns_counts = CSV.read(filename, col_sep: separator).map(&:size).uniq
      columns_counts.size == 1 && columns_counts.first > 1
    end
  end
end
