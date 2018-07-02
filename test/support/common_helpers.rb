# frozen_string_literal: true

module CommonHelpers

  def array_match(expected, actual)
    expected_sorted = expected.first.is_a?(Hash) ? expected.sort_by(&:first) : expected.sort
    actual_sorted = expected.first.is_a?(Hash) ? actual.sort_by(&:first) : actual.sort
    expected_sorted == actual_sorted
  end

  def ordered_elements(page, elements)
    clean_text = ::ActionController::Base.helpers.strip_tags(page.body).gsub(/\n|\s/, "")
    clean_text =~ Regexp.new(elements.join(".*").gsub(/\n|\s/, ""))
  end

  def has_link_to?(location)
    all("a[href='#{location}']").any?
  end

end
