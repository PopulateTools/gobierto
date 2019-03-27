# frozen_string_literal: true

require "test_helper"

module GobiertoCalendars
  class FilteringRuleApplierTest < ActiveSupport::TestCase
    def test_filter_two_rules
      rule1 = GobiertoCalendars::FilteringRule.new field: :title, action: :ignore, value: "@", condition: :contains, remove_filtering_text: true
      rule2 = GobiertoCalendars::FilteringRule.new field: :title, action: :import_as_draft, value: "@", condition: :contains, remove_filtering_text: false

      result = GobiertoCalendars::FilteringRuleApplier.filter({ title: "Foo @ Bar" }, [rule1, rule2])
      assert_equal GobiertoCalendars::FilteringRuleApplier::REMOVE, result.action
      assert_equal "Foo Bar", result.event_attributes[:title]
      assert_equal GobiertoCalendars::FilteringRuleApplier::REMOVE, GobiertoCalendars::FilteringRuleApplier.filter({ title: "Foo @ Bar" }, [rule1, rule2]).action
      assert_equal GobiertoCalendars::FilteringRuleApplier::REMOVE, GobiertoCalendars::FilteringRuleApplier.filter({ title: "Foo @ Bar" }, [rule1]).action
      assert_equal GobiertoCalendars::FilteringRuleApplier::CREATE_PENDING, GobiertoCalendars::FilteringRuleApplier.filter({ title: "Foo @ Bar" }, [rule2]).action
      assert_equal GobiertoCalendars::FilteringRuleApplier::CREATE, GobiertoCalendars::FilteringRuleApplier.filter({ title: "Foo @ Bar" }, []).action
      assert_equal GobiertoCalendars::FilteringRuleApplier::CREATE, GobiertoCalendars::FilteringRuleApplier.filter({ title: "Foo Bar" }, [rule1, rule2]).action
      assert_equal GobiertoCalendars::FilteringRuleApplier::CREATE, GobiertoCalendars::FilteringRuleApplier.filter({ title: nil }, [rule1, rule2]).action
    end

    def test_filter_single_rule
      rule1 = GobiertoCalendars::FilteringRule.new field: :title, action: :ignore, value: "[Wadus]", condition: :not_contains

      assert_equal GobiertoCalendars::FilteringRuleApplier::CREATE, GobiertoCalendars::FilteringRuleApplier.filter({ title: "[Wadus]" }, [rule1]).action
      assert_equal GobiertoCalendars::FilteringRuleApplier::REMOVE, GobiertoCalendars::FilteringRuleApplier.filter({ title: "Foo" }, [rule1]).action
    end
  end
end
