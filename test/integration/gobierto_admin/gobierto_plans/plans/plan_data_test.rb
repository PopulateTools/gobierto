# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class PlanDataTest < ActionDispatch::IntegrationTest
      def setup
        super
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

      def test_create_node
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do

              visit admin_plans_plan_data_path(plan)

              within "#jsGrid" do
                click_button "Switch to inserting"
                within ".jsgrid-insert-row" do
                  cells = all(:xpath, "td")

                  (3..4).each do |index|
                    cells[index].all("input").each do |input_element|
                      input_element.set("Test Plan Node")
                    end
                  end

                  select "People and families", from: "category-0-new"
                  select "Provide social assistance to individuals and families who need it for lack of resources", from: "category-1-new"
                  select "Scholarships for families in the Central District", from: "category-2-new"
                  click_button "Insert"
                end
              end

              sleep 1
              assert has_content? "Test Plan Node"
              node = plan.nodes.last
              assert_equal "Test Plan Node", node.name
            end
          end
        end
      end

      def test_create_node_invalid
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do

              visit admin_plans_plan_data_path(plan)

              within "#jsGrid" do
                click_button "Switch to inserting"
                within ".jsgrid-insert-row" do
                  cells = all(:xpath, "td")
                  cells[4].all("input").each do |input_element|
                    input_element.set("Test Plan Node")
                  end
                  click_button "Insert"
                end
              end

              assert_match "Invalid data entered!", page.driver.browser.modal_message
              refute has_content? "Test Plan Node"
            end
          end
        end
      end

    end
  end
end
