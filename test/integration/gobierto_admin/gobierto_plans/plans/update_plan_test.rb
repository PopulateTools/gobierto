# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class UpdatePlanTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = new_admin_plans_plan_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def plan
        @plan ||= gobierto_plans_plans(:strategic_plan)
      end

      def test_update_plan
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_plans_plan_path(plan.slug)

            within "form" do
              fill_in "plan_title_translations_en", with: "Edited plan title"
              fill_in "plan_title_for_menu_translations_en", with: "Edited plan title menu"

              click_button "Update"
            end

            assert has_message? "Plan updated successfully."

            visit admin_plans_path

            assert has_content? "Edited plan title"

            plan.reload

            assert_equal "Edited plan title", plan.title
            assert_equal "Edited plan title menu", plan.title_for_menu

            activity = Activity.last
            assert_equal plan, activity.subject
            assert_equal admin, activity.author
            assert_equal site.id, activity.site_id
            assert_equal "gobierto_plans.plan_updated", activity.action
          end
        end
      end
    end
  end
end
