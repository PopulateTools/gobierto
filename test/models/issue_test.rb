# frozen_string_literal: true

require "test_helper"

class IssueTest < ActiveSupport::TestCase
  def issue
    @issue ||= issues(:culture)
  end

  def test_valid
    assert issue.valid?
  end
end
