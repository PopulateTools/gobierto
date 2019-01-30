# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoBudgets
    class OptionsTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_gobierto_budgets_options_path
      end

      def site
        @site ||= sites(:madrid)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def cms_page
        @cms_page ||= gobierto_cms_pages(:about_site)
      end

      def test_enable_options
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              assert has_content?("Options")

              refute find("#gobierto_budgets_options_elaboration_enabled", visible: false).checked?
              refute find("#gobierto_budgets_options_budget_lines_feedback_enabled", visible: false).checked?
              assert find("#gobierto_budgets_options_receipt_enabled", visible: false).checked?
              refute find("#gobierto_budgets_options_comparison_tool_enabled", visible: false).checked?
              refute find("#gobierto_budgets_options_providers_enabled", visible: false).checked?
              refute find("#gobierto_budgets_options_indicators_enabled", visible: false).checked?

              find("#gobierto_budgets_options_elaboration_enabled", visible: false).trigger(:click)
              find("#gobierto_budgets_options_budget_lines_feedback_enabled", visible: false).trigger(:click)
              fill_in "gobierto_budgets_options_feedback_emails", with: "email@example.com"
              fill_in "gobierto_budgets_options_receipt_configuration", with: "{}"

              find("#gobierto_budgets_options_comparison_tool_enabled", visible: false).trigger(:click)
              find("#gobierto_budgets_options_comparison_context_table_enabled", visible: false).trigger(:click)
              find("#gobierto_budgets_options_comparison_tool_enabled", visible: false).trigger(:click)
              find("#gobierto_budgets_options_indicators_enabled", visible: false).trigger(:click)
              select cms_page.title, from: "gobierto_budgets_options_budgets_guide_page"

              click_button "Save"

              assert has_message?("Settings saved successfully")
              assert find("#gobierto_budgets_options_elaboration_enabled", visible: false).checked?
              assert find("#gobierto_budgets_options_budget_lines_feedback_enabled", visible: false).checked?
              assert has_field?("gobierto_budgets_options_feedback_emails", with: "email@example.com")
              assert find("#gobierto_budgets_options_receipt_enabled", visible: false).checked?
              assert has_field?("gobierto_budgets_options_receipt_configuration", with: "{}")
              refute find("#gobierto_budgets_options_comparison_tool_enabled", visible: false).checked?
              refute find("#gobierto_budgets_options_comparison_context_table_enabled", visible: false).checked?
              assert find("#gobierto_budgets_options_indicators_enabled", visible: false).checked?
              assert has_field?("gobierto_budgets_options_budgets_guide_page", with: cms_page.id)
            end
          end
        end
      end

      def test_update_annual_budgets_data
        with_signed_in_admin(admin) do
          with_current_site(site) do
            with_stubbed_s3_upload! do
              visit @path

              click_link("Generate budget lines by year files")

              assert has_message?("Process to generate files of budget lines by year launched")
            end
          end
        end
      end
    end
  end
end
