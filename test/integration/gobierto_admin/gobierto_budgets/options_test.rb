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

      def test_enable_options
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            assert has_content?("Options")

            refute has_checked_field?("gobierto_budgets_options_elaboration_enabled")
            refute has_checked_field?("gobierto_budgets_options_budget_lines_feedback_enabled")

            check "gobierto_budgets_options_elaboration_enabled"
            check "gobierto_budgets_options_budget_lines_feedback_enabled"
            fill_in "gobierto_budgets_options_feedback_emails", with: "email@example.com"
            check "gobierto_budgets_options_receipt_enabled"
            fill_in "gobierto_budgets_options_receipt_configuration", with: "{}"
            click_button "Save"

            assert has_checked_field?("gobierto_budgets_options_elaboration_enabled")
            assert has_checked_field?("gobierto_budgets_options_budget_lines_feedback_enabled")
            assert has_field?("gobierto_budgets_options_feedback_emails", with: "email@example.com")
            assert has_field?("gobierto_budgets_options_receipt_configuration", with: "{}")

            assert has_message?("Settings saved successfully")
          end
        end
      end
    end
  end
end
