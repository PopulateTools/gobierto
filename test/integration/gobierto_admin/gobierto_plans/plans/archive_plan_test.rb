# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class ArchivePlanTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_plans_plans_path
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

      def test_archive_restore_plan
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#plan-item-#{plan.id}" do
                find("a[data-method='delete']").click
              end

              assert has_message?("Plan archived successfully")

              click_on "Archived elements"

              within "div#archived-plan-list" do
                within "tr#plan-item-#{plan.id}" do
                  click_on "Recover element"
                end
              end

              assert has_message?("Plan has been successfully recovered")
            end
          end
        end
      end
    end
  end
end
