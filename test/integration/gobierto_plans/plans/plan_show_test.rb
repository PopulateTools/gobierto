# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_plans_plan_path(slug: plan_type.slug, year: plan.year)
    end

    def site
      @site ||= sites(:madrid)
    end

    def plan
      @plan ||= gobierto_plans_plans(:strategic_plan)
    end

    def plan_type
      @plan_type ||= plan.plan_type
    end

    def axes
      @axes ||= CollectionDecorator.new(plan.categories.where(level: 0).sorted, decorator: GobiertoPlans::CategoryTermDecorator)
    end

    def action_lines
      @action_lines ||= CollectionDecorator.new(plan.categories.where(level: 1).sorted, decorator: GobiertoPlans::CategoryTermDecorator)
    end

    def actions
      @actions ||= CollectionDecorator.new(plan.categories.where(level: 2).sorted, decorator: GobiertoPlans::CategoryTermDecorator)
    end

    def projects
      node_ids = GobiertoPlans::CategoriesNode.where(category_id: actions.pluck(:id)).pluck(:node_id)
      @projects ||= GobiertoPlans::Node.where(id: node_ids)
    end

    def project_with_progress
      @project_with_progress ||= gobierto_plans_nodes(:political_agendas)
    end

    def test_plan
      with_javascript do
        with_current_site(site) do
          visit @path

          assert has_content? "Strategic Plan introduction"

          within "div.header-detail" do
            assert has_content? "#{axes.count} axes"
            assert has_content? "1 line of action"
            assert has_content? "#{actions.count} actions"
            assert has_content? "#{projects.published.count} project"
          end

          within "section.level_0" do
            assert has_selector?("div.node-root", count: axes.count)

            axes.each_with_index do |axe, index|
              assert has_selector?("div.node-root.cat_#{index + 1}")

              within "div.node-root.cat_#{index + 1}" do
                assert has_content?(axe.name.to_s)
              end
            end
          end

          assert has_content? "Strategic Plan footer"
        end
      end
    end

    def test_progress_precission
      project_with_progress.update_attribute(:progress, 2.666666666666666)

      with_javascript do
        with_current_site(site) do
          visit @path

          assert has_content? "Strategic Plan introduction"

          within "div.header-resume" do
            within "span" do
              assert has_content? "1.3%"
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
              assert has_content?("25%")
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
            within "div.node-root.cat_1" do
              find("a").click
            end
          end

          within ".planification-content" do
            within "section.level_1.cat_1" do
              within ".lines-header" do
                assert has_content?("1 line of action")
              end

              within ".lines-list" do
                assert has_content?(action_lines.first.name)
                assert has_content?("2 actions")

                assert has_content?((projects.sum(:progress) / projects.count).to_i.to_s + "%")
              end

              assert has_selector?("h3", text: action_lines.first.name)
              find("h3", text: action_lines.first.name).click
            end

            within "section.level_2.cat_1" do
              assert has_content?(action_lines.first.name)

              within "ul.action-line--list" do
                assert has_selector?("li", count: actions.count)

                find("h3", text: actions.first.name).click
                assert has_selector?("div", text: projects.last.progress.to_i.to_s + "%")

                find("td", text: projects.first.name).click

                assert has_content?(projects.first.status.name)
              end
            end
          end
        end
      end
    end

    def test_show_table_header
      with_javascript do
        with_current_site(site) do
          visit @path

          within "section.level_0" do
            within "div.node-root.cat_1" do
              find("a").click
            end
          end

          within ".planification-content" do
            within "section.level_1.cat_1" do
              find("h3", text: action_lines.first.name).click
            end

            within "section.level_2.cat_1" do
              within "ul.action-line--list" do
                find("h3", text: actions.first.name).click
                assert has_no_selector?("thead", count: 1)
              end
            end
          end

          hash = plan.configuration_data
          hash["show_table_header"] = true
          plan.update_attribute(:configuration_data, JSON.pretty_generate(hash))

          visit @path

          within "section.level_0" do
            within "div.node-root.cat_1" do
              find("a").click
            end
          end

          within ".planification-content" do
            within "section.level_1.cat_1" do
              find("h3", text: action_lines.first.name).click
            end

            within "section.level_2.cat_1" do
              within "ul.action-line--list" do
                find("h3", text: actions.first.name).click
                assert has_selector?("thead", count: 1)
              end
            end
          end
        end
      end
    end

    def test_plan_breadcrumbs
      with_javascript do
        with_current_site(site) do
          visit @path

          hash = plan.configuration_data
          hash["open_node"] = true
          plan.update_attribute(:configuration_data, JSON.pretty_generate(hash))

          within "section.level_0" do
            within "div.node-root.cat_1" do
              find("a").click
            end
          end

          within ".planification-content" do
            within "section.level_1.cat_1" do
              find("h3", text: action_lines.first.name).click
            end

            within "section.level_2.cat_1" do
              within "ul.action-line--list" do
                find("h3", text: actions.first.name).click
              end
              assert has_selector?("div.node-breadcrumb")

              within "ul.action-line--list" do
                find("td", text: projects.first.name).click
              end
            end

            all("div.node-breadcrumb")[0].click

            within ".lines-header" do
              assert has_content?("1 line of action")
            end
          end
        end
      end
    end

    def test_draft_plan
      with_current_site(site) do
        plan.draft!

        visit @path

        assert_equal 404, page.status_code
      end
    end

    def test_plan_without_configuration
      plan.update_attribute(:configuration_data, "")

      with_javascript do
        with_current_site(site) do
          visit @path

          within "section.level_0" do
            within "div.node-root.cat_1" do
              find("a").click
            end
          end

          within ".planification-content" do
            within "section.level_1.cat_1" do
              within ".lines-header" do
                assert has_content?("1 item of level 3")
              end

              within ".lines-list" do
                assert has_content?(action_lines.first.name)
                assert has_content?("2 items of level 4")

                assert has_content?((projects.sum(:progress) / projects.count).to_i.to_s + "%")
              end

              assert has_selector?("h3", text: action_lines.first.name)
              find("h3", text: action_lines.first.name).click
            end

            within "section.level_2.cat_1" do
              assert has_content?(action_lines.first.name)

              within "ul.action-line--list" do
                assert has_selector?("li", count: actions.count)

                find("h3", text: actions.first.name).click
                assert has_selector?("div", text: projects.last.progress.to_i.to_s + "%")

                find("td", text: projects.first.name).click

                assert has_content?(projects.first.status.name)
              end
            end
          end
        end
      end
    end
  end
end
