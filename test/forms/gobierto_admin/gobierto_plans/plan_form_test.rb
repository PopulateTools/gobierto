# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class PlanFormTest < ActiveSupport::TestCase
      def valid_plan_form
        @valid_plan_form ||= PlanForm.new(
          site_id: site.id,
          title_translations: { I18n.locale => plan.title },
          slug: "#{plan.slug}-2",
          plan_type_id: plan.plan_type.id,
          introduction_translations: { I18n.locale => plan.introduction },
          css: plan.css,
          configuration_data: plan.configuration_data,
          year: plan.year + 1,
          vocabulary_id: vocabulary.id
        )
      end

      def invalid_plan_form
        @invalid_plan_form ||= PlanForm.new(
          site_id: site.id,
          title_translations: nil,
          slug: nil,
          plan_type_id: plan.plan_type.id,
          introduction_translations: nil,
          css: nil,
          configuration_data: nil,
          year: nil
        )
      end

      def plan
        @plan ||= gobierto_plans_plans(:strategic_plan)
      end

      def site
        @site ||= sites(:madrid)
      end

      def vocabulary
        @vocabulary ||= gobierto_common_vocabularies(:plan_categories_vocabulary)
      end

      def test_save_plan_with_valid_attributes
        assert valid_plan_form.save
      end

      def test_save_existing_plan_with_blank_vocabulary
        valid_plan_form.vocabulary_id = nil

        assert valid_plan_form.save

        valid_plan_form.save
        assert_equal 1, valid_plan_form.errors.messages[:vocabulary_id].size
      end

      def test_plan_error_messages_with_invalid_attributes_wadus
        invalid_plan_form.save

        assert_equal 1, invalid_plan_form.errors.messages[:title].size
        assert_equal 1, invalid_plan_form.errors.messages[:introduction].size
        assert_equal 1, invalid_plan_form.errors.messages[:year].size
        assert_equal 0, invalid_plan_form.errors.messages[:slug].size
        assert_equal 0, invalid_plan_form.errors.messages[:css].size
        assert_equal 0, invalid_plan_form.errors.messages[:configuration_data].size
      end
    end
  end
end
