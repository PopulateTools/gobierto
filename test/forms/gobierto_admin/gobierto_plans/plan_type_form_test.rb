# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class PlanTypeFormTest < ActiveSupport::TestCase
      def valid_plan_type_form
        @valid_plan_type_form ||= PlanTypeForm.new(
          name: plan_type.name,
          slug: "#{plan_type.slug}-2"
        )
      end

      def invalid_plan_type_form
        @invalid_plan_type_form ||= PlanTypeForm.new(
          name: nil,
          slug: nil
        )
      end

      def plan_type
        @plan ||= gobierto_plans_plan_types(:pam)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_save_plan_type_with_valid_attributes
        assert valid_plan_type_form.save
      end

      def test_plan_type_error_messages_with_invalid_attributes_wadus
        invalid_plan_type_form.save

        assert_equal 1, invalid_plan_type_form.errors.messages[:name].size
        assert_equal 0, invalid_plan_type_form.errors.messages[:slug].size
      end
    end
  end
end
