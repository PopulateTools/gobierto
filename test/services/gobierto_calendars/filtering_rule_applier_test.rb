# frozen_string_literal: true

require "test_helper"

module GobiertoCalendars
  class FilteringRuleApplierTest < ActiveSupport::TestCase
    def test_filter
      rule1 = GobiertoCalendars::FilteringRule.new field: :title, action: :ignore, value: "@", condition: :contains
      rule2 = GobiertoCalendars::FilteringRule.new field: :title, action: :import_as_draft, value: "@", condition: :contains

      assert_equal GobiertoCalendars::FilteringRuleApplier::REMOVE, GobiertoCalendars::FilteringRuleApplier.filter({title: "Foo @ Bar"}, [rule1, rule2])
      assert_equal GobiertoCalendars::FilteringRuleApplier::REMOVE, GobiertoCalendars::FilteringRuleApplier.filter({title: "Foo @ Bar"}, [rule1])
      assert_equal GobiertoCalendars::FilteringRuleApplier::CREATE_PENDING, GobiertoCalendars::FilteringRuleApplier.filter({title: "Foo @ Bar"}, [rule2])
      assert_equal GobiertoCalendars::FilteringRuleApplier::CREATE, GobiertoCalendars::FilteringRuleApplier.filter({title: "Foo @ Bar"}, [])
      assert_equal GobiertoCalendars::FilteringRuleApplier::REMOVE, GobiertoCalendars::FilteringRuleApplier.filter({title: "Foo Bar"}, [rule1, rule2])
    end
  end
end
