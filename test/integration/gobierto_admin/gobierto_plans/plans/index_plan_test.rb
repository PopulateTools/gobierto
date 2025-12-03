# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class IndexPlanTest < ActionDispatch::IntegrationTest
      include Integration::AdminGroupsConcern

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

      def plan
        @plan ||= gobierto_plans_plans(:strategic_plan)
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

      def test_plan_link_for_editors
        allow_regular_admin_edit_all_projects

        with(site: site, admin: regular_admin) do
          visit @path

          click_link plan.title
          within "table#projects" do
            plan.nodes.each do |project|
              assert has_selector?("tr#project-item-#{project.id}")
            end
          end
        end
      end

      def test_plan_link_for_moderators
        allow_regular_admin_moderate_all_projects

        with(site: site, admin: regular_admin) do
          visit @path

          click_link plan.title
          within "table#projects" do
            plan.nodes.each do |project|
              assert has_selector?("tr#project-item-#{project.id}")
            end
          end
        end
      end
    end
  end
end
