# frozen_string_literal: true

require "test_helper"

class IssueTest < ActiveSupport::TestCase
  def issue
    @issue ||= issues(:culture)
  end

  def test_valid
    assert issue.valid?
  end

  def test_find_by_slug
    assert_nil Issue.find_by_slug! nil
    assert_nil Issue.find_by_slug! ""
    assert_raises(ActiveRecord::RecordNotFound) do
      Issue.find_by_slug!("foo")
    end

    assert_equal issue, Issue.find_by_slug!(issue.slug_es)
    assert_equal issue, Issue.find_by_slug!(issue.slug_en)
  end
end
