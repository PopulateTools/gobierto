# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class PlanDataFormTest < ActiveSupport::TestCase
      def uploaded_csv_file
        @uploaded_csv_file ||= ActionDispatch::Http::UploadedFile.new(
          filename: "plan_example_file.csv",
          tempfile: file_fixture("gobierto_admin/gobierto_plans/plan_example_file.csv")
        )
      end

      def plan
        @plan ||= gobierto_plans_plans(:strategic_plan)
      end

      def site
        @site ||= sites(:madrid)
      end

      def valid_plan_data_form
        @valid_plan_data_form ||= PlanDataForm.new(
          plan: plan,
          csv_file: uploaded_csv_file
        )
      end

      def test_plan_data_upload
        valid_plan_data_form.save

        assert_equal 2, plan.categories.where(level: 0).count
        assert_equal 4, plan.categories.where(level: 1).count
        assert_equal 9, plan.categories.where(level: 2).count
        assert_equal 16, plan.nodes.count

        uploaded_node = ::GobiertoPlans::Node.with_name_translation("In Progress 2 Transportation B", site.configuration.default_locale).first
        refute_nil uploaded_node
        assert_equal "Active", uploaded_node.status
        assert_equal 75.0, uploaded_node.progress
        assert_equal Date.parse("2016-06-04"), uploaded_node.starts_at
        assert_equal Date.parse("2018-12-31"), uploaded_node.ends_at
        assert_equal "project", uploaded_node.options["Type"]
        assert_equal "Wadus", uploaded_node.options["Goals"]
        assert uploaded_node.options.has_key? "Custom Field 1"
        assert_equal "Sample", uploaded_node.options["Custom Field 1"]
      end
    end
  end
end
