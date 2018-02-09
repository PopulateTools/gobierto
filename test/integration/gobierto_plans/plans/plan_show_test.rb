# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_plans_plan_path(plan.slug)
    end

    def site
      @site ||= sites(:madrid)
    end

    def plan
      @plan ||= gobierto_plans_plans(:strategic_plan)
    end

    def axes
      @axes ||= plan.categories.where(level: 0)
    end

    def action_lines
      @action_lines ||= plan.categories.where(level: 1)
    end

    def actions
      @actions ||= plan.categories.where(level: 2)
    end

    def projects
      node_ids = GobiertoPlans::CategoriesNode.where(category_id: actions.pluck(:id)).pluck(:node_id)
      @projects ||= GobiertoPlans::Node.where(id: node_ids)
    end

    def test_plan
      with_javascript do
        with_current_site(site) do
          visit @path

          assert has_content? "FOLLOW THE EVOLUTION OF THE GOVERNMENT PLAN"
          assert has_content? "Latest update: November 01, 2016"

          assert has_content? "#{axes.size} axes"
          assert has_content? "#{action_lines.size} lines of action"
          assert has_content? "#{actions.size} actions"
          assert has_content? "#{projects.size} projects"

          within "section.level_0" do
            assert has_selector?("div.node-root", count: axes.size)

            axes.each_with_index do |axe, index|
              assert has_selector?("div.node-root.cat_#{index + 1}")

              within "div.node-root.cat_#{index + 1}" do
                assert has_content?(axe.name.to_s)
              end
            end
          end
        end
      end
    end

    def test_global_execution
      with_javascript do
        with_current_site(site) do
          visit @path
          within "div.header-resume" do
            within "span" do
              assert has_content?("0.08333333333333334")
            end
          end
        end
      end
    end

    def test_navigating_tree
      with_javascript do
        with_current_site(site) do
          visit @path

          within "section.level_0" do
            within "div.node-root.cat_3" do
              find("a").trigger("click")
            end
          end

          within ".planification-content" do
            within "section.level_1.cat_3" do
              within ".lines-header" do
                assert has_content?("#{action_lines.size} lines of action")
              end
              within ".lines-list" do
                assert has_content?(action_lines.first.name)
                assert has_content?("#{actions.size} actions")

                assert has_content?((projects.sum(:progress) / projects.size) / 100)
              end

              assert has_selector?("h3", text: action_lines.first.name)
              find("h3", text: action_lines.first.name).click
            end
            within "section.level_2.cat_3" do
              assert has_content?(action_lines.first.name)

              within "ul.action-line--list" do
                assert has_selector?("li", count: actions.size)

                find("h3", text: actions.first.name).click
                assert has_selector?("div", text: (projects.last.progress / 100).to_s)

                find("td", text: projects.first.name).click
              end
            end

            within "section.level_3.cat_3" do
              find("h3", text: projects.first.name)
              assert has_content?(projects.first.status)
            end
          end
        end
      end
    end
  end
end
