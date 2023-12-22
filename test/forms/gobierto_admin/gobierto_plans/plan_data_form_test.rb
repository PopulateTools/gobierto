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

      def uploaded_csv_case_changed_file
        @uploaded_csv_case_changed_file ||= ActionDispatch::Http::UploadedFile.new(
          filename: "plan_example_file.csv",
          tempfile: file_fixture("gobierto_admin/gobierto_plans/plan_example_file_case_changed.csv")
        )
      end

      def plan
        @plan ||= gobierto_plans_plans(:strategic_plan)
      end

      def site
        @site ||= sites(:madrid)
      end

      def csv_import_statuses_vocabulary
        @csv_import_statuses_vocabulary = gobierto_common_vocabularies(:plan_csv_import_statuses_vocabulary)
      end

      def valid_plan_data_form
        @valid_plan_data_form ||= PlanDataForm.new(
          plan: plan,
          csv_file: uploaded_csv_file
        )
      end

      def valid_plan_data_case_changed_form
        @valid_plan_data_case_changed_form ||= PlanDataForm.new(
          plan: plan,
          csv_file: uploaded_csv_case_changed_file
        )
      end

      def test_plan_data_upload_with_wrong_statuses_vocabulary
        refute valid_plan_data_form.save
      end

      def test_plan_data_upload_with_statuses_vocabulary
        plan.update_attribute(:statuses_vocabulary_id, csv_import_statuses_vocabulary.id)
        plan.nodes.each(&:destroy)

        assert valid_plan_data_form.save

        assert_equal 2, plan.categories.where(level: 0).count
        assert_equal 4, plan.categories.where(level: 1).count
        assert_equal 9, plan.categories.where(level: 2).count
        assert_equal 16, plan.nodes.count

        uploaded_node = ::GobiertoPlans::Node.with_name_translation("In Progress 2 Transportation B", site.configuration.default_locale).first
        refute_nil uploaded_node
        assert_equal "Active", uploaded_node.status.name
        assert_equal 75.0, uploaded_node.progress
        assert_equal Date.parse("2016-06-04"), uploaded_node.starts_at
        assert_equal Date.parse("2018-12-31"), uploaded_node.ends_at
        assert_equal "ext_16", uploaded_node.external_id

        custom_fields_values = {
          "description" => /This is a description to be saved in a custom field/,
          "madrid-vocabulary-single-select" => /Bird/,
          "madrid-vocabulary-multiple-select" => /Bird,Swift,Pigeon/,
          "madrid-vocabulary-tags" => /Pigeon/,
          "madrid-vocabulary-tags" => /New tag, with comma/
        }

        custom_fields_values.each do |uid, value|
          assert_match value, uploaded_node.custom_field_record_with_uid(uid).value_string
        end
      end

      def test_plan_data_case_changed_upload_with_statuses_vocabulary
        plan.update_attribute(:statuses_vocabulary_id, csv_import_statuses_vocabulary.id)
        plan.nodes.each(&:destroy)

        assert valid_plan_data_case_changed_form.save

        assert_equal 2, plan.categories.where(level: 0).count
        assert_equal 4, plan.categories.where(level: 1).count
        assert_equal 9, plan.categories.where(level: 2).count
        assert_equal 16, plan.nodes.count

        uploaded_node = ::GobiertoPlans::Node.with_name_translation("In Progress 2 Transportation B", site.configuration.default_locale).first
        refute_nil uploaded_node
        assert_equal "Active", uploaded_node.status.name
        assert_equal 75.0, uploaded_node.progress
        assert_equal Date.parse("2016-06-04"), uploaded_node.starts_at
        assert_equal Date.parse("2018-12-31"), uploaded_node.ends_at
        assert_equal "ext_16", uploaded_node.external_id

        custom_fields_values = {
          "description" => /This is a description to be saved in a custom field/,
          "madrid-vocabulary-single-select" => /Bird/,
          "madrid-vocabulary-multiple-select" => /Bird,Swift,Pigeon/,
          "madrid-vocabulary-tags" => /Pigeon/,
          "madrid-vocabulary-tags" => /New tag, with comma/
        }

        custom_fields_values.each do |uid, value|
          assert_match value, uploaded_node.custom_field_record_with_uid(uid).value_string
        end
      end
    end
  end
end
