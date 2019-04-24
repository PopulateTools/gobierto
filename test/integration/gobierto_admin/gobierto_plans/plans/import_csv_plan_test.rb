# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class ImportCsvPlanTest < ActionDispatch::IntegrationTest
      include Integration::AdminGroupsConcern

      attr_reader :plan, :path

      def setup
        super
        @plan = gobierto_plans_plans(:strategic_plan)
        @path = edit_admin_plans_plan_path(plan)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_import_csv_without_file
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit path

            click_link "Import from CSV"

            within "form" do
              click_button "Import from CSV file"
            end

            assert has_alert? "Please, choose a file for the import."
          end
        end
      end

      def test_import_csv_file
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit path

            click_link "Import from CSV"

            attach_file("plan_csv_file", "test/fixtures/files/gobierto_plans/plan2.csv")
            within "form" do
              with_stubbed_s3_file_upload do
                click_button "Import from CSV file"
              end
            end

            assert has_message? "Data imported successfully"

            assert has_content? "5 axes"
            assert has_content? "39 lines of action"
            assert has_content? "119 actions"
            assert has_content? "247 projects/actions"

            plan.reload
            assert_equal 247, plan.nodes.count
          end
        end
      end

      def test_regular_admin_manager_import
        allow_regular_admin_manage_plans

        with_signed_in_admin(regular_admin) do
          with_current_site(site) do
            visit path

            click_link "Import from CSV"

            attach_file("plan_csv_file", "test/fixtures/files/gobierto_plans/plan.csv")
            within "form" do
              with_stubbed_s3_file_upload do
                click_button "Import from CSV file"
              end
            end

            assert has_message? "Data imported successfully"
          end
        end
      end

      def test_regular_admin_editor_import
        allow_regular_admin_edit_plans
        @path = admin_plans_plan_import_csv_path(plan)

        with_signed_in_admin(regular_admin) do
          with_current_site(site) do
            visit path

            assert has_alert? "You are not authorized to perform this action"
          end
        end
      end

      def test_regular_admin_moderator_import
        allow_regular_admin_moderate_plans
        @path = admin_plans_plan_import_csv_path(plan)

        with_signed_in_admin(regular_admin) do
          with_current_site(site) do
            visit path

            assert has_alert? "You are not authorized to perform this action"
          end
        end
      end
    end
  end
end
