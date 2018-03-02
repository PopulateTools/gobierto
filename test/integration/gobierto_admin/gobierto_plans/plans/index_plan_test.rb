# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class IndexPlanTest < ActionDispatch::IntegrationTest
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

      def plans
        @plans ||= site.plans
      end

      def test_plan_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "table#plans" do
              plans.each do |plan|
                assert has_selector?("tr#plan-item-#{plan.id}")

                within "tr#plan-item-#{plan.id}" do
                  assert has_link?("View plan")
                end
              end
            end
          end
        end
      end
    end
  end
end
