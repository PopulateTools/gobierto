# frozen_string_literal: true

require "test_helper"

module GobiertoCalendars
  class FilteringRuleApplierTest < ActiveSupport::TestCase
    def test_filter_two_rules
      rule1 = GobiertoCalendars::FilteringRule.new field: :title, action: :ignore, value: "@", condition: :contains
      rule2 = GobiertoCalendars::FilteringRule.new field: :title, action: :import_as_draft, value: "@", condition: :contains

      assert_equal GobiertoCalendars::FilteringRuleApplier::REMOVE, GobiertoCalendars::FilteringRuleApplier.filter({title: "Foo @ Bar"}, [rule1, rule2])
      assert_equal GobiertoCalendars::FilteringRuleApplier::REMOVE, GobiertoCalendars::FilteringRuleApplier.filter({title: "Foo @ Bar"}, [rule1])
      assert_equal GobiertoCalendars::FilteringRuleApplier::CREATE_PENDING, GobiertoCalendars::FilteringRuleApplier.filter({title: "Foo @ Bar"}, [rule2])
      assert_equal GobiertoCalendars::FilteringRuleApplier::CREATE, GobiertoCalendars::FilteringRuleApplier.filter({title: "Foo @ Bar"}, [])
      assert_equal GobiertoCalendars::FilteringRuleApplier::CREATE, GobiertoCalendars::FilteringRuleApplier.filter({title: "Foo Bar"}, [rule1, rule2])
      assert_equal GobiertoCalendars::FilteringRuleApplier::CREATE, GobiertoCalendars::FilteringRuleApplier.filter({title: nil}, [rule1, rule2])
    end

    def test_filter_single_rule
      rule1 = GobiertoCalendars::FilteringRule.new field: :title, action: :ignore, value: "[Wadus]", condition: :not_contains

      assert_equal GobiertoCalendars::FilteringRuleApplier::CREATE, GobiertoCalendars::FilteringRuleApplier.filter({title: "[Wadus]"}, [rule1])
      assert_equal GobiertoCalendars::FilteringRuleApplier::REMOVE, GobiertoCalendars::FilteringRuleApplier.filter({title: "Foo"}, [rule1])
    end
  end
end
