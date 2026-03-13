# frozen_string_literal: true

require "test_helper"

class CsvUtilsTest < Minitest::Test
  def comma_separated_file
    Rails.root.join("test/fixtures/files/csv_utils/comma_separated.csv")
  end

  def test_detect_separator_returns_comma_for_comma_separated_file
    assert_equal ",", CsvUtils.detect_separator(comma_separated_file)
  end
end
