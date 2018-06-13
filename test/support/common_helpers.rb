# frozen_string_literal: true

module CommonHelpers
  def array_match(expected, actual)
    expected_sorted = expected.first.is_a?(Hash) ? expected.sort_by(&:first) : expected.sort
    actual_sorted = expected.first.is_a?(Hash) ? actual.sort_by(&:first) : actual.sort
    expected_sorted == actual_sorted
  end
end
