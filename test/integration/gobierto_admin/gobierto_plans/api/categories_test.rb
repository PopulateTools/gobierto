# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    module Api
      class CategoriesTest < ActionDispatch::IntegrationTest

        def site
          @site ||= sites(:madrid)
        end

        def regular_admin
          @regular_admin ||= gobierto_admin_admins(:steve)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def plan
          @plan ||= gobierto_plans_plans(:strategic_plan)
        end

        def category_term
          @category_term ||= gobierto_common_terms(:center_basic_needs_plan_term)
        end

        def test_permissions_not_signed_in
          with_current_site(site) do
            visit admin_plans_api_plan_categories_path(plan)

            assert has_message? "We need you to sign in to continue"
          end
        end

        def test_permissions_regular_admin
          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit admin_plans_api_plan_categories_path(plan)

              assert has_message? "You are not authorized to perform this action"
            end
          end
        end

        def test_permissions_admin
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit admin_plans_api_plan_categories_path(plan)

              assert has_content? category_term.name
            end
          end
        end

        def test_index
          with_current_site(site) do
            login_admin_for_api(admin)

            get admin_plans_api_plan_categories_path(plan)

            assert_response :success
            response_data = JSON.parse response.body
            assert_equal plan.categories_vocabulary.terms.count, response_data.count
          end
        end

      end
    end
  end
end
