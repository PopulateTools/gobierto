# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class PlanDataTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_plans_plan_data_path(plan)
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

      def node
        @node ||= gobierto_plans_nodes(:political_agendas)
      end

      def test_create_node
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do

              visit @path

              click_link "New node"
              within "#jsGrid" do
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
                  find(".fa-check").click
                end
              end

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

              visit @path

              click_link "New node"
              within "#jsGrid" do
                within ".jsgrid-insert-row" do
                  cells = all(:xpath, "td")
                  cells[4].all("input").each do |input_element|
                    input_element.set("Test Plan Node")
                  end
                  find(".fa-check").click
                end
              end

              assert_match "Invalid data entered", page.driver.browser.modal_message
              assert has_no_content? "Test Plan Node"
            end
          end
        end
      end

      def test_index
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do

              visit @path

              assert has_content? "Publish political agendas"
            end
          end
        end
      end

      def test_edit_node
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do

              visit @path

              within "#jsGrid" do
                find(".jsgrid-cell", text: node.name).click
                within ".jsgrid-edit-row" do
                  cells = all(:xpath, "td")
                  cells[3].all("input").each do |input_element|
                    input_element.set("Updated Plan Node")
                  end
                  find(".fa-check").click
                end
              end
              assert has_content? "Updated Plan Node"

              node.reload
              assert_equal "Updated Plan Node", node.name
            end
          end
        end
      end

      def test_delete_node
        initial_nodes_count = plan.nodes.count
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do

              visit @path

              accept_alert do
                first(".fa-trash").click
              end

              sleep 1
              assert_equal initial_nodes_count - 1, plan.nodes.count
            end
          end
        end
      end

      def test_plan_without_vocabulary
        plan.update_attribute(:vocabulary_id, nil)
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              assert has_content? "No categories was found."
            end
          end
        end
      end

    end
  end
end
