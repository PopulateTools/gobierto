# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class PlansControllerTest < GobiertoControllerTest

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def plan
        @plan ||= gobierto_plans_plans(:strategic_plan)
      end

      def empty_plan
        @empty_plan ||= gobierto_plans_plans(:government_plan)
      end

      def plan_with_projects_with_blank_status
        @plan_with_projects_with_blank_status ||= gobierto_plans_plans(:economic_plan)
      end

      def plan_with_indicators
        @plan_with_indicators ||= gobierto_plans_plans(:multiple_indicators_plan)
      end

      def plan_without_indicators
        @plan_without_indicators ||= gobierto_plans_plans(:government_plan)
      end

      def project
        @project ||= gobierto_plans_nodes(:political_agendas)
      end

      def project_custom_fields
        @project_custom_fields ||= [:madrid_node_global,
                                    :madrid_plans_custom_field_localized_description,
                                    :madrid_plans_custom_field_color,
                                    :madrid_plans_custom_field_image,
                                    :madrid_plans_custom_field_vocabulary_single_select,
                                    :madrid_plans_custom_field_vocabulary_multiple_select,
                                    :madrid_plans_custom_field_vocabulary_tags,
                                    :madrid_custom_field_budgets_plugin,
                                    :madrid_custom_field_progress_plugin,
                                    :madrid_custom_field_table_plugin,
                                    :madrid_custom_field_human_resources_table_plugin,
                                    :madrid_custom_field_indicators_table_plugin].map { |id| gobierto_common_custom_fields(id) }
      end

      def test_export_csv
        with(site: site, admin: admin) do
          get admin_plans_plan_export_csv_url(plan)

          assert_response :success
          assert_equal "text/csv", response.content_type

          parsed_response = CSV.parse(response.body, headers: true)
          assert_equal 2, parsed_response.length
          last_row = parsed_response[1]
          last_row_headers = last_row.headers

          assert_equal project.categories.first.parent_term.parent_term.name, last_row["Level 0"]
          assert_equal project.categories.first.parent_term.name, last_row["Level 1"]
          assert_equal project.categories.first.name, last_row["Level 2"]
          assert_equal project.name, last_row["Node.Title"]
          assert_equal project.status.name, last_row["Node.Status"]
          assert_equal project.progress, last_row["Node.Progress"].to_f
          assert_equal project.starts_at, Date.parse(last_row["Node.Start"])
          assert_equal project.ends_at, Date.parse(last_row["Node.End"])
          project_custom_fields.each do |project_custom_field|
            if project_custom_field.csv_importable?
              assert_includes last_row_headers, "Node.#{project_custom_field.uid}"
              custom_field_record = project.custom_field_record_with_uid(project_custom_field.uid)
              assert_equal custom_field_record.value_string, last_row["Node.#{project_custom_field.uid}"]
            else
              refute_includes last_row_headers, "Node.#{project_custom_field.uid}"
            end
          end
        end
      end

      def test_export_csv_empty_plan
        with(site: site, admin: admin) do
          get admin_plans_plan_export_csv_url(empty_plan)

          assert_response :success
          assert_equal "text/csv", response.content_type

          parsed_response = CSV.parse(response.body, headers: true)
          assert_equal 3, parsed_response.length
          parsed_response.each do |row|
            assert_nil row["Node.Progress"]
          end
        end
      end

      def test_export_csv_plan_with_projects_with_blank_status
        with(site: site, admin: admin) do
          get admin_plans_plan_export_csv_url(plan_with_projects_with_blank_status)

          assert_response :success
          assert_equal "text/csv", response.content_type

          parsed_response = CSV.parse(response.body, headers: true)
          assert_equal 1, parsed_response.length
          assert_equal "0.0", parsed_response[0]["Node.Progress"]
        end
      end

      def test_export_csv_indicator_with_with_indicators
        with(site: site, admin: admin) do
          get admin_plans_plan_export_indicator_csv_path(plan_with_indicators)

          assert_response :success
          assert_equal "text/csv", response.content_type

          parsed_response = CSV.parse(response.body, headers: true)
          assert_equal 6, parsed_response.length
          assert_equal "Government Statistical", parsed_response[0]["Node.Title"]
        end
      end

      def test_export_csv_indicator_without_indicators
        with(site: site, admin: admin) do
          get admin_plans_plan_export_indicator_csv_path(plan_without_indicators)

          assert_response :success
          assert_equal "text/csv", response.content_type

          parsed_response = CSV.parse(response.body, headers: true)
          assert_equal 0, parsed_response.length
        end
      end

    end
  end
end
