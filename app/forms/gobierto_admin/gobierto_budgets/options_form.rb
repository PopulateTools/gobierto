# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoBudgets
    class OptionsForm < BaseForm

      attr_accessor(
        :site,
        :elaboration_enabled,
        :budget_lines_feedback_enabled,
        :feedback_emails,
        :receipt_enabled,
        :receipt_configuration,
        :comparison_tool_enabled,
        :comparison_context_table_enabled,
        :comparison_compare_municipalities_enabled,
        :comparison_compare_municipalities,
        :comparison_show_widget,
        :providers_enabled,
        :indicators_enabled,
        :budgets_guide_page
      )

      validates :site, presence: true
      validates :feedback_emails, presence: true, if: Proc.new{ |of| of.budget_lines_feedback_enabled? }
      validates :receipt_configuration, presence: true, if: Proc.new{ |of| of.receipt_enabled? }
      validate :receipt_configuration_format, if: Proc.new{ |of| of.receipt_enabled? }

      def elaboration_enabled
        @elaboration_enabled ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["budgets_elaboration"]
      end

      def elaboration_enabled?
        elaboration_enabled == true || elaboration_enabled == '1'
      end

      def budget_lines_feedback_enabled
        @budget_lines_feedback_enabled ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["budget_lines_feedback_enabled"]
      end

      def budget_lines_feedback_enabled?
        budget_lines_feedback_enabled == true || budget_lines_feedback_enabled == '1'
      end

      def feedback_emails
        @feedback_emails ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["feedback_emails"]
      end

      def receipt_enabled
        @receipt_enabled ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["budgets_receipt_enabled"]
      end

      def receipt_enabled?
        receipt_enabled == true || receipt_enabled == '1'
      end

      def receipt_configuration
        @receipt_configuration ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["budgets_receipt_configuration"]
      end

      def comparison_tool_enabled
        comparison_context_table_enabled? || comparison_compare_municipalities_enabled || comparison_show_widget?
      end

      def comparison_context_table_enabled?
        comparison_context_table_enabled == true || comparison_context_table_enabled == '1'
      end

      def comparison_context_table_enabled
        @comparison_context_table_enabled ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["comparison_context_table_enabled"]
      end

      def comparison_compare_municipalities_enabled
        @comparison_compare_municipalities_enabled.present? ? @comparison_compare_municipalities_enabled != '0' : comparison_compare_municipalities.present?
      end

      def comparison_compare_municipalities
        @comparison_compare_municipalities ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["comparison_compare_municipalities"] || []
      end

      def comparison_compare_municipalities_text
        if comparison_compare_municipalities.any?
          comparison_compare_municipalities.map do |place_id|
            [INE::Places::Place.find(place_id).name, place_id]
          end
        else
          []
        end
      end

      def comparison_show_widget?
        comparison_show_widget == '1' || comparison_show_widget == true
      end

      def comparison_show_widget
        @comparison_show_widget ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["comparison_show_widget"]
      end

      def providers_enabled
        @providers_enabled ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["budgets_providers_enabled"]
      end

      def providers_enabled?
        providers_enabled == true || providers_enabled == '1'
      end

      def indicators_enabled
        @indicators_enabled ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["budgets_indicators_enabled"]
      end

      def indicators_enabled?
        indicators_enabled == true || indicators_enabled == '1'
      end

      def budgets_guide_page
        @budgets_guide_page ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["budgets_guide_page"]
      end

      def save
        save_options if valid?
      end

      private

      def save_options
        settings = {}
        settings[:budgets_elaboration] = elaboration_enabled if elaboration_enabled?
        settings[:budget_lines_feedback_enabled] = budget_lines_feedback_enabled if budget_lines_feedback_enabled?
        settings[:feedback_emails] = budget_lines_feedback_enabled? ? feedback_emails : nil
        settings[:budgets_receipt_enabled] = receipt_enabled if receipt_enabled?
        settings[:budgets_receipt_configuration] = receipt_enabled? ? receipt_configuration : nil
        settings[:comparison_context_table_enabled] = comparison_context_table_enabled? ? comparison_context_table_enabled : nil
        settings[:comparison_compare_municipalities] = comparison_compare_municipalities_enabled ? comparison_compare_municipalities.map(&:to_i).select{ |i| i > 0 } : nil
        settings[:comparison_show_widget] = comparison_show_widget? ? comparison_show_widget : nil
        settings[:budgets_providers_enabled] = providers_enabled if providers_enabled?
        settings[:budgets_indicators_enabled] = indicators_enabled if indicators_enabled?
        settings[:budgets_guide_page] = budgets_guide_page

        if site.gobierto_budgets_settings.nil?
          GobiertoModuleSettings.create! site: site, module_name: "GobiertoBudgets", settings: settings
        else
          site.gobierto_budgets_settings.update_attribute :settings, settings
        end
      end

      def receipt_configuration_format
        return if receipt_configuration.blank? || receipt_configuration.is_a?(Hash)

        JSON.parse(receipt_configuration)
      rescue JSON::ParserError
        errors.add :receipt_configuration, I18n.t('errors.messages.invalid')
      end
    end
  end
end
