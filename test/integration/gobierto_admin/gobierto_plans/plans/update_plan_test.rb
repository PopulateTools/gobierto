# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/previewable_item_test_module"

module GobiertoAdmin
  module GobiertoPlans
    class UpdatePlanTest < ActionDispatch::IntegrationTest
      include ::GobiertoAdmin::PreviewableItemTestModule

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

      def preview_test_conf
        {
          item_admin_path: edit_admin_plans_plan_path(plan),
          item_public_url: gobierto_plans_plan_url(plan.plan_type.slug, plan.year, host: site.domain)
        }
      end

      def test_update_plan
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_plans_plan_path(plan)

            within "form" do
              fill_in "plan_title_translations_en", with: "Edited plan title"

              select "Animals", from: "plan_statuses_vocabulary_id"
              click_button "Update"
            end

            assert has_message? "Plan updated successfully."

            visit admin_plans_plans_path

            assert has_content? "Edited plan title"

            plan.reload

            assert_equal "Edited plan title", plan.title
            assert_equal "Animals", plan.statuses_vocabulary.name

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
