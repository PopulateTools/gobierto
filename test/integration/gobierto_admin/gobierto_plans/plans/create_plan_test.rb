# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class CreatePlanTest < ActionDispatch::IntegrationTest
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

      def test_create_plan
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              fill_in "plan_title_translations_en", with: "New plan title"
              fill_in "plan_title_for_menu_translations_en", with: "New plan title for menu"
              fill_in "plan_introduction_translations_en", with: "New plan introduction"

              click_link "ES"

              fill_in "plan_title_translations_es", with: "Título del nuevo plan"
              fill_in "plan_title_for_menu_translations_es", with: "Título del menú del nuevo plan"
              fill_in "plan_introduction_translations_es", with: "Introducción del nuevo plan"

              select "pam", from: "plan_plan_type_id"

              click_button "Create"

              assert has_message? "Plan created successfully"

              plan = site.plans.last

              assert_equal "New plan title", plan.title
              assert_equal "New plan title for menu", plan.title_for_menu
              assert_equal "New plan introduction", plan.introduction

              assert_equal "Título del nuevo plan", plan.title_es
              assert_equal "Título del menú del nuevo plan", plan.title_for_menu_es
              assert_equal "Introducción del nuevo plan", plan.introduction_es

              assert_equal "pam", plan.plan_type.name
              assert_equal "new-plan-title", plan.slug

              activity = Activity.last
              assert_equal plan, activity.subject
              assert_equal admin, activity.author
              assert_equal site.id, activity.site_id
              assert_equal "gobierto_plans.plan_created", activity.action
            end
          end
        end
      end
    end
  end
end
