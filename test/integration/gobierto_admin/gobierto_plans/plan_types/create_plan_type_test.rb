# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class CreatePlanTypeTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = new_admin_plans_plan_type_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_create_plan_type
        with(js: true) do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              fill_in "plan_type_name_translations_en", with: "New plan type title"

              click_link "ES"

              fill_in "plan_type_name_translations_es", with: "Título del nuevo tipo de plan"

              click_button "Create"

              assert has_message? "Plan type created successfully."

              plan_type = ::GobiertoPlans::PlanType.last

              assert_equal "New plan type title", plan_type.name

              assert_equal "Título del nuevo tipo de plan", plan_type.name_es

              assert_equal "new-plan-type-title", plan_type.slug

              activity = Activity.last
              assert_equal plan_type, activity.subject
              assert_equal admin, activity.author
              assert_equal site.id, activity.site_id
              assert_equal "gobierto_plans.plan_type_created", activity.action
            end
          end
        end
      end
    end
  end
end
