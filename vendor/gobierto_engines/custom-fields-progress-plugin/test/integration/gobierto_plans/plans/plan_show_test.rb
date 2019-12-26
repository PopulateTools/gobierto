# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_plans_plan_path(slug: plan_type.slug, year: plan.year)
      plan.touch
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

    def action_lines
      @action_lines ||= CollectionDecorator.new(plan.categories.where(level: 1).sorted, decorator: GobiertoPlans::CategoryTermDecorator).to_a
    end

    def actions
      @actions ||= CollectionDecorator.new(plan.categories.where(level: 2).sorted, decorator: GobiertoPlans::CategoryTermDecorator).to_a
    end

    def projects
      node_ids = GobiertoPlans::CategoriesNode.where(category_id: actions.pluck(:id)).pluck(:node_id)
      @projects ||= GobiertoPlans::Node.where(id: node_ids)
    end

    def published_project
      @published_project ||= gobierto_plans_nodes(:political_agendas)
    end

    alias project_with_progress published_project

    def draft_projects
      @draft_projects ||= plan.nodes.draft
    end

    def human_resources_record
      @human_resources_record ||= gobierto_common_custom_field_records(:political_agendas_human_resources_table_custom_field_record)
    end

    def publish_last_version_on_all_projects!
      projects.each do |project|
        project.published!
        project.update_attribute(:published_version, project.versions.count)
      end
      plan.touch
    end

    def test_native_progress_is_ignored
      project_with_progress.update_attribute(:progress, 2.666666666666666)
      plan.touch

      with(site: site, js: true) do
        visit @path

        assert has_content? "Strategic Plan introduction"

        within "div.header-resume" do
          within "span" do
            assert has_content? "100%"
          end
        end
      end
    end

    def test_global_execution
      with(site: site, js: true) do
        visit @path
        within "div.header-resume" do
          within "span" do
            assert has_content?("100%")
          end
        end
      end
    end

    def test_global_execution_with_all_nodes_published
      publish_last_version_on_all_projects!
      with(site: site, js: true) do
        visit @path
        within "div.header-resume" do
          within "span" do
            assert has_content?("50%")
          end
        end
      end
    end

    def test_draft_project
      with(site: site, js: true) do
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

              assert has_content?("100%")
            end

            assert has_selector?("h3", text: action_lines.first.name)
            find("h3", text: action_lines.first.name).click
          end

          within "section.level_2.cat_1" do
            assert has_content?(action_lines.first.name)

            within "ul.action-line--list" do
              assert has_selector?("li", count: actions.count)

              find("h3", text: actions.first.name).click
              assert has_no_content? draft_projects.first.name

              find("h3", text: actions.last.name).click
              assert has_no_content? published_project.name
            end
          end
        end
      end
    end

    def test_versioned_project
      published_project.paper_trail.save_with_version
      published_project.update_attribute(:ends_at, 2.days.from_now)
      human_resources_record.update(
        payload:
        {
          human_resources_table: [
            {
              human_resource: ActiveRecord::FixtureSet.identify(:human_resources_supervisor),
              cost: 35_000,
              start_date: 1.day.ago.to_date.to_s,
              end_date: 1.day.from_now.to_date.to_s
            }
          ]
        },
        item_has_versions: true
      )

      plan.touch

      with(site: site, js: true) do
        visit @path

        within "div.header-resume" do
          assert has_content?("100%")
        end

        published_project.update_attribute(:published_version, 2)
        plan.touch

        visit @path

        within "div.header-resume" do
          assert has_content?("50%")
        end
      end
    end

  end
end
