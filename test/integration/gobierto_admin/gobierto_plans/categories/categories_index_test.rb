# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    module Categories
      class CategoriesIndexTest < ActionDispatch::IntegrationTest
        include Integration::AdminGroupsConcern

        def setup
          super
          @path = admin_plans_plan_categories_path(plan)
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

        def test_admin_categories_index
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "div.pure-u-md-1-3", text: "Global progress" do
                within "div.metric_value" do
                  assert has_content? "25%"
                end
              end
            end
          end
        end
      end
    end
  end
end
