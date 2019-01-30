# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoBudgets
    class OptionsFormTest < ActiveSupport::TestCase

      def site
        @site ||= sites(:madrid)
      end

      def page
        @page ||= gobierto_cms_pages(:site_news_1)
      end

      def receipt_configuration
        @receipt_configuration ||= <<-JSON
{
  "budgets_simulation_sections": [{
    "name_es": "IBI",
    "name_ca": "IBI",
    "options": [{
      "name_es": "Vivienda 80m2 en el centro",
      "name_ca": "Habitatge 80m2 al centre",
      "value": "377.29€"
    },
    {
      "name": "Vivienda 130m2 en el centro",
      "value": "582.13€"
    },
    {
      "name": "Adosado en centro urbano",
      "value": " 749.15€"
    },
    {
      "name": "Vivienda unifamiliar en urbanización",
      "value": "680.94€"
    }
    ]
  }]
}
JSON
      end

      def valid_form
        @valid_form ||= OptionsForm.new(
          site: site,
          elaboration_enabled: '1',
          budget_lines_feedback_enabled: '1',
          feedback_emails: 'email1@example.com',
          receipt_enabled: '1',
          receipt_configuration: receipt_configuration,
          comparison_context_table_enabled: '1',
          comparison_compare_municipalities: [28065, 28001],
          comparison_show_widget: '1',
          providers_enabled: '1',
          budgets_guide_page: page.id
        )
      end

      def valid_form_feedback_disabled
        @valid_form ||= OptionsForm.new(
          site: site,
          elaboration_enabled: '1',
          budget_lines_feedback_enabled: '0',
          receipt_enabled: '1',
          receipt_configuration: receipt_configuration,
          comparison_context_table_enabled: '1',
          comparison_compare_municipalities: [28065, 28001],
          comparison_show_widget: '1',
          providers_enabled: '1',
        )
      end

      def invalid_form_receipt_configuration_wrong
        @invalid_form_receipt_configuration_wrong ||= OptionsForm.new(
          site: site,
          elaboration_enabled: '1',
          budget_lines_feedback_enabled: '0',
          receipt_enabled: '1',
          receipt_configuration: 'invalid_json',
          providers_enabled: '1'
        )
      end

      def invalid_form
        @invalid_form ||= OptionsForm.new(
          site: site,
          elaboration_enabled: '1',
          budget_lines_feedback_enabled: '1',
          receipt_enabled: '1',
          receipt_configuration: '',
          comparison_context_table_enabled: '0',
          comparison_compare_municipalities: [],
          comparison_show_widget: '0',
          providers_enabled: '1'
        )
      end

      def test_save_valid_form
        assert valid_form.save

        site.reload
        assert site.gobierto_budgets_settings.settings["budgets_elaboration"]
        assert site.gobierto_budgets_settings.settings["budget_lines_feedback_enabled"]
        assert_equal "email1@example.com", site.gobierto_budgets_settings.settings["feedback_emails"]
        assert site.gobierto_budgets_settings.settings["budgets_receipt_enabled"]
        assert_equal receipt_configuration, site.gobierto_budgets_settings.settings["budgets_receipt_configuration"]
        assert site.gobierto_budgets_settings.settings["budgets_providers_enabled"]
        assert site.gobierto_budgets_settings.settings["budgets_guide_page"]
      end

      def test_save_valid_form_feedback_disabled
        assert valid_form_feedback_disabled.valid?
        assert valid_form_feedback_disabled.save

        site.reload
        assert site.gobierto_budgets_settings.settings["budgets_elaboration"]
        refute site.gobierto_budgets_settings.settings["budget_lines_feedback_enabled"]
        assert site.gobierto_budgets_settings.settings["budgets_receipt_enabled"]
        assert site.gobierto_budgets_settings.settings["budgets_providers_enabled"]
        refute site.gobierto_budgets_settings.settings["budgets_guide_page"]
      end

      def test_error_messages_with_invalid_attributes
        invalid_form.save

        assert_equal 1, invalid_form.errors.messages[:feedback_emails].size
        assert_equal 1, invalid_form.errors.messages[:receipt_configuration].size
      end

      def test_error_messages_with_invalid_json
        invalid_form_receipt_configuration_wrong.save

        assert_equal 1, invalid_form_receipt_configuration_wrong.errors.messages[:receipt_configuration].size
      end

      def test_comparison_tool_enabled
        assert valid_form.comparison_tool_enabled
        refute invalid_form.comparison_tool_enabled
      end

      def test_comparison_compare_municipalities_enabled
        assert valid_form.comparison_compare_municipalities_enabled
        refute invalid_form.comparison_compare_municipalities_enabled
      end
    end
  end
end
