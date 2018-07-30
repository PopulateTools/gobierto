# frozen_string_literal: true

require "test_helper"

class ScopeTest < ActiveSupport::TestCase
  def scope
    @scope ||= gobierto_common_terms(:center_term)
  end

  def test_valid
    assert scope.valid?
  end
end
