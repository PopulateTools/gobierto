# frozen_string_literal: true

require "test_helper"

class ScopeTest < ActiveSupport::TestCase
  def scope
    @scope ||= gobierto_common_scopes(:center)
  end

  def test_valid
    assert scope.valid?
  end
end
