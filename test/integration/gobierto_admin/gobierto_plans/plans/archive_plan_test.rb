# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class ArchivePlanTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_plans_plans_path
        plan.update_attribute(:plan_type_id, plan_type.id)
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

      def plan_type
        @plan_type ||= gobierto_plans_plan_types(:pu)
      end

      def test_archive_plan_and_delete_plan_type
        with(site: site, admin: admin, js: true) do
          visit @path

          within "#plan-item-#{plan.id}" do
            find("a[data-method='delete']").click
          end

          page.accept_alert

          assert has_message?("Plan archived successfully")
          plan_type.destroy
          visit @path
          assert has_no_content? plan.title
        end
      end

      def test_archive_restore_plan
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#plan-item-#{plan.id}" do
                find("a[data-method='delete']").click
              end

              page.accept_alert

              assert has_message?("Plan archived successfully")

              click_on "Archived elements"

              within "div#archived-plan-list" do
                within "tr#plan-item-#{plan.id}" do
                  click_on "Recover element"
                end
              end

              page.accept_alert

              assert has_message?("Plan has been successfully recovered")
            end
          end
        end
      end
    end
  end
end
