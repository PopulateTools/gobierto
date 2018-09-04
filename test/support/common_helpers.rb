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

  def preview_link_includes_token?
    find_link("View item")[:href].include?("preview_token=")
  end

  def preview_link_excludes_token?
    find_link("View item")[:href].exclude?("preview_token=")
  end

  def click_preview_link
    click_link "View item"
  end

end
