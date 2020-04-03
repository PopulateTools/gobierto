# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class ImportCsvPlanTest < ActionDispatch::IntegrationTest
      include Integration::AdminGroupsConcern

      attr_reader :plan, :path, :statuses_vocabulary

      def setup
        super
        @statuses_vocabulary = gobierto_common_vocabularies(:plan_csv_import_statuses_vocabulary)
        @plan = gobierto_plans_plans(:strategic_plan)
        @plan.update_attribute(:statuses_vocabulary_id, statuses_vocabulary.id)
        @path = edit_admin_plans_plan_path(plan)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def custom_field_vocabulary
        @custom_field_vocabulary ||= gobierto_common_vocabularies(:animals)
      end

      def test_delete_projects
        with(admin: admin, site: site) do
          visit path

          click_link "Delete projects of this plan"

          assert has_message?("Plan projects has been successfully deleted")

          assert @plan.nodes.blank?
          assert @plan.categories_vocabulary.terms.blank?
          assert @plan.statuses_vocabulary.terms.blank?
          assert custom_field_vocabulary.terms.blank?
        end
      end
    end
  end
end
