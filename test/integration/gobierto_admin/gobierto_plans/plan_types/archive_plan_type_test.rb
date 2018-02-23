# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class ArchivePlanTypeTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_plans_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def plan_type
        @plan_type ||= gobierto_plans_plan_types(:pu)
      end

      def plan_type_with_items
        @plan_type_with_items ||= gobierto_plans_plan_types(:pam)
      end

      def test_archive_restore_plan_type
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#plan-type-item-#{plan_type.id}" do
                find("a[data-method='delete']").click
              end

              assert has_message?("Plan type archived successfully")

              click_on "Archived elements"

              within "div#archived-plan-type-list" do
                within "tr#plan-type-item-#{plan_type.id}" do
                  click_on "Recover element"
                end
              end

              assert has_message?("Plan type has been successfully recovered")
            end
          end
        end
      end

      def test_cant_archive_plan_type
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#plan-type-item-#{plan_type_with_items.id}" do
                find("a[data-method='delete']").click
              end

              assert has_message?("You can't archive a type of plan while having associated elements.")
            end
          end
        end
      end
    end
  end
end
