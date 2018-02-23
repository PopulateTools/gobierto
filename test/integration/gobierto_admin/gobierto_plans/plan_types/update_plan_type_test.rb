# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class UpdatePlanTypeTest < ActionDispatch::IntegrationTest
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

      def plan_type
        @plan_type ||= gobierto_plans_plan_types(:pam)
      end

      def test_update_plan_type
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_plans_plan_type_path(plan_type.slug)

            within "form" do
              fill_in "plan_type_name", with: "Edited plan type name"

              click_button "Update"
            end

            assert has_message? "Plan type updated successfully."

            visit admin_plans_path

            assert has_content? "Edited plan type name"

            plan_type.reload

            assert_equal "Edited plan type name", plan_type.name

            activity = Activity.last
            assert_equal plan_type, activity.subject
            assert_equal admin, activity.author
            assert_equal site.id, activity.site_id
            assert_equal "gobierto_plans.plan_type_updated", activity.action
          end
        end
      end
    end
  end
end
