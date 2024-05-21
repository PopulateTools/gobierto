# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_budgets/describable_test"

class GobiertoBudgets::EconomicAreaTest < ActiveSupport::TestCase
  include GobiertoBudgets::DescribableTest

  def test_all_items
    items = GobiertoBudgets::EconomicArea.all_items
    assert_kind_of Hash, items
    assert_includes items.keys, "G"
    assert_includes items.keys, "I"
  end
end
