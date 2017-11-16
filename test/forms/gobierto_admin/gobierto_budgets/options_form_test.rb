# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoBudgets
    class OptionsFormTest < ActiveSupport::TestCase

      def site
        @site ||= sites(:madrid)
      end

      def valid_form
        @valid_form ||= OptionsForm.new(
          site: site,
          elaboration_enabled: '1',
          budget_lines_feedback_enabled: '1',
          feedback_emails: 'email1@example.com'
        )
      end

      def valid_form_feedback_disabled
        @valid_form ||= OptionsForm.new(
          site: site,
          elaboration_enabled: '1',
          budget_lines_feedback_enabled: '0'
        )
      end

      def invalid_form
        @valid_form ||= OptionsForm.new(
          site: site,
          elaboration_enabled: '1',
          budget_lines_feedback_enabled: '1'
        )
      end

      def test_save_valid_form
        assert valid_form.save

        site.reload
        assert site.gobierto_budgets_settings.settings["budgets_elaboration"]
        assert site.gobierto_budgets_settings.settings["budget_lines_feedback_enabled"]
        assert_equal "email1@example.com", site.gobierto_budgets_settings.settings["feedback_emails"]
      end

      def test_save_valid_form_feedback_disabled
        assert valid_form_feedback_disabled.valid?
        assert valid_form_feedback_disabled.save

        site.reload
        assert site.gobierto_budgets_settings.settings["budgets_elaboration"]
        refute site.gobierto_budgets_settings.settings["budget_lines_feedback_enabled"]
      end

      def test_error_messages_with_invalid_attributes
        invalid_form.save

        assert_equal 1, invalid_form.errors.messages[:feedback_emails].size
      end
    end
  end
end
