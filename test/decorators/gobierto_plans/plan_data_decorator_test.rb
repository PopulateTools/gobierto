# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanDataDecoratorTest < ActiveSupport::TestCase
    def plan
      @plan ||= gobierto_plans_plans(:strategic_plan)
    end

    def first_category
      @first_category ||= GobiertoPlans::CategoryTermDecorator.new(plan.categories.where(level: plan.categories.maximum(:level)).order(:position).first)
    end

    def last_category
      @last_category ||= GobiertoPlans::CategoryTermDecorator.new(plan.categories.where(level: plan.categories.maximum(:level)).order(:position).last)
    end

    def first_node
      @first_node ||= first_category.nodes.first
    end

    def last_node
      @last_node ||= last_category.nodes.last
    end

    def csv_file
      @csv_file ||= Rails.root.join("test/fixtures/files/gobierto_plans/plan.csv")
    end

    def existing_plan_csv
      @existing_plan_csv ||= Rails.root.join("test/fixtures/files/gobierto_plans/strategic-plan-update.csv")
    end

    def sample_import_csv_file
      @sample_import_csv_file ||= Rails.root.join("test/fixtures/files/gobierto_plans/plan2.csv")
    end

    def csv_import_statuses_vocabulary
      @csv_import_statuses_vocabulary = gobierto_common_vocabularies(:plan_csv_import_statuses_vocabulary)
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

    def test_csv_export
      csv_output = CSV.parse(GobiertoPlans::PlanDataDecorator.new(plan).csv, headers: true)
      csv_headers = csv_output.headers

      assert_equal first_category.parent_term.parent_term.name, csv_output.by_row[0]["Level 0"]
      assert_equal first_category.parent_term.name, csv_output.by_row[0]["Level 1"]
      assert_equal first_category.name, csv_output.by_row[0]["Level 2"]
      assert_equal first_node.name, csv_output.by_row[0]["Node.Title"]
      assert_equal first_node.status.name, csv_output.by_row[0]["Node.Status"]
      assert_equal first_node.progress, csv_output.by_row[0]["Node.Progress"].to_f
      assert_equal first_node.starts_at, Date.parse(csv_output.by_row[0]["Node.Start"])
      assert_equal first_node.ends_at, Date.parse(csv_output.by_row[0]["Node.End"])
      project_custom_fields.each do |project_custom_field|
        if project_custom_field.csv_importable?
          assert_includes csv_headers, "Node.#{project_custom_field.uid}"
          custom_field_record = first_node.custom_field_record_with_uid(project_custom_field.uid)
          if custom_field_record.present?
            assert_equal custom_field_record.value_string, csv_output.by_row[0]["Node.#{project_custom_field.uid}"]
          else
            assert_nil csv_output.by_row[0]["Node.#{project_custom_field.uid}"]
          end
        else
          refute_includes csv_headers, "Node.#{project_custom_field.uid}"
        end
      end
    end

    def test_csv_import_with_empty_plan
      plan.update_attribute(:statuses_vocabulary_id, csv_import_statuses_vocabulary.id)
      plan.nodes.each(&:destroy)

      csv_input = CSV.read(csv_file, headers: true)
      csv_headers = csv_input.headers

      GobiertoAdmin::GobiertoPlans::PlanDataForm.new(csv_file: csv_file, plan: plan).save

      assert_equal csv_input.by_row[0]["Level 1"], first_category.parent_term.parent_term.name
      assert_equal csv_input.by_row[0]["Level 2"], first_category.parent_term.name
      assert_equal csv_input.by_row[0]["Level 3"], first_category.name
      assert_equal csv_input.by_row[0]["Node.Title"], first_node.name
      assert_equal csv_input.by_row[0]["Node.Status"], first_node.status.name
      assert_equal csv_input.by_row[0]["Node.Progress"].to_f, first_node.progress
      assert_equal Date.parse(csv_input.by_row[0]["Node.Start"]), first_node.starts_at
      assert_equal Date.parse(csv_input.by_row[0]["Node.End"]), first_node.ends_at

      extra_headers = csv_headers - ["Level 1", "Level 2", "Level 3", "Node.Title", "Node.Status", "Node.Progress", "Node.Start", "Node.End", "Node.external_id"]

      extra_headers.each do |extra_header|
        uid = extra_header.gsub(/\ANode\./, "")
        custom_field_record = first_node.custom_field_records.joins(:custom_field).find_by(custom_fields: { uid: uid })
        assert_equal csv_input.by_row[0][extra_header], custom_field_record.value_string&.strip
      end
      refute first_node.published?
      refute first_node.published_version.present?
      assert first_node.moderation.approved?
    end

    def test_sample_csv_import_with_empty_plan_and_automatic_publication
      plan.update(statuses_vocabulary_id: csv_import_statuses_vocabulary.id, publish_last_version_automatically: true)
      plan.nodes.each(&:destroy)

      GobiertoAdmin::GobiertoPlans::PlanDataForm.new(csv_file: sample_import_csv_file, plan: plan).save

      assert_equal 2, plan.categories_vocabulary.terms.where(level: 2).with_name_translation("76. Avaluar les poítiques d'Igualtat mitjançant un sistema d'indicadors de gènere").count
      refute plan.nodes.draft.exists?
      assert_equal plan.nodes.count, plan.nodes.with_moderation_stage(:approved).count
    end

    def test_csv_import_with_existing_projects_and_not_found_categories
      plan.update_attribute(:statuses_vocabulary_id, csv_import_statuses_vocabulary.id)

      form = GobiertoAdmin::GobiertoPlans::PlanDataForm.new(csv_file: sample_import_csv_file, plan: plan)
      refute form.save
      assert_match(/One of the categories couldn't be found/, form.errors.full_messages.first)
    end

    def test_csv_import_with_existing_projects_and_compatible_categories
      csv_input = CSV.read(existing_plan_csv, headers: true)
      csv_headers = csv_input.headers

      form = GobiertoAdmin::GobiertoPlans::PlanDataForm.new(csv_file: existing_plan_csv, plan: plan)

      assert_difference "plan.nodes.count", 1 do
        assert form.save
      end

      assert_equal csv_input.by_row[0]["Level 0"], first_category.parent_term.parent_term.name
      assert_equal csv_input.by_row[0]["Level 1"], first_category.parent_term.name
      assert_equal csv_input.by_row[0]["Level 2"], first_category.name
      assert_equal csv_input.by_row[0]["Node.Title"], first_node.name
      assert_equal csv_input.by_row[0]["Node.Status"], first_node.status.name
      assert_equal csv_input.by_row[0]["Node.Progress"].to_f, first_node.progress
      assert_equal Date.parse(csv_input.by_row[0]["Node.Start"]), first_node.starts_at
      assert_equal Date.parse(csv_input.by_row[0]["Node.End"]), first_node.ends_at

      extra_headers = csv_headers - ["Level 0", "Level 1", "Level 2", "Level 3", "Node.Title", "Node.Status", "Node.Progress", "Node.Start", "Node.End", "Node.external_id"]

      extra_headers.each do |extra_header|
        uid = extra_header.gsub(/\ANode\./, "")
        custom_field_record = first_node.custom_field_records.joins(:custom_field).find_by(custom_fields: { uid: uid })
        if csv_input.by_row[0][extra_header].blank?
          assert custom_field_record.value_string.blank?
        else
          assert_equal csv_input.by_row[0][extra_header], custom_field_record.value_string.strip
        end
      end
      refute first_node.published?
      refute first_node.published_version.present?
      assert first_node.moderation.approved?
    end
  end
end
