# frozen_string_literal: true

require "test_helper"

module GobiertoCalendars
  class FilteringRuleTest < ActiveSupport::TestCase
    def filtering_rule
      @filtering_rule ||= GobiertoCalendars::FilteringRule.new field: :title, action: :ignore, value: "@", condition: :not_contains
    end

    def test_apply
      assert_equal "ignore", filtering_rule.apply({
        title: "Foo",
        description: "Bar"
      })

      assert_equal false, filtering_rule.apply({
        title: "@ Foo",
        description: "Bar"
      })

      assert_equal "import", filtering_rule.apply({
        title: nil,
        description: "Bar"
      })
    end

    def test_conditions
      filtering_rule.condition = :contains
      assert_equal "ignore", filtering_rule.apply({ title: "Foo @ Bar" })
      assert_equal false, filtering_rule.apply({ title: "Foo Bar" })

      filtering_rule.condition = :not_contains
      assert_equal false, filtering_rule.apply({ title: "Foo @ Bar" })
      assert_equal "ignore", filtering_rule.apply({ title: "Foo Bar" })

      filtering_rule.condition = :starts_with
      assert_equal "ignore", filtering_rule.apply({ title: "@ Foo Bar" })
      assert_equal false, filtering_rule.apply({ title: "Foo @ Bar" })

      filtering_rule.condition = :ends_with
      assert_equal "ignore", filtering_rule.apply({ title: "Foo Bar @" })
      assert_equal false, filtering_rule.apply({ title: "Foo @ Bar" })

      filtering_rule.condition = :not_starts_with
      assert_equal false, filtering_rule.apply({ title: "@ Foo Bar" })
      assert_equal "ignore", filtering_rule.apply({ title: "Foo @ Bar" })
    end

    def test_update_event_attributes
      updated_event_attributes = filtering_rule.update_event_attributes({ title: "Foo @ Bar" })
      assert_equal "Foo Bar", updated_event_attributes[:title]
    end
  end
end
