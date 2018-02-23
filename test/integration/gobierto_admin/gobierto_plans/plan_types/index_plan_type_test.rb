# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class IndexPlanTypeTest < ActionDispatch::IntegrationTest
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

      def plan_types
        @plan_types ||= ::GobiertoPlans::PlanType.all
      end

      def test_plan_types_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "table#plan_types" do
              plan_types.each do |plan_type|
                assert has_selector?("tr#plan-type-item-#{plan_type.id}")
              end
            end
          end
        end
      end
    end
  end
end
