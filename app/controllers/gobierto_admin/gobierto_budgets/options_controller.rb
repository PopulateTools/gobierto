module GobiertoAdmin
  module GobiertoBudgets
    class OptionsController < BaseController
      before_action { module_enabled!(current_site,  'GobiertoBudgets') }
      before_action { module_allowed!(current_admin, 'GobiertoBudgets') }

      def index
        @available_pages = get_available_pages
        @options_form = GobiertoAdmin::GobiertoBudgets::OptionsForm.new(site: current_site)
        @services_config = get_services_config
      end

      def update
        @available_pages = get_available_pages
        @services_config = get_services_config
        @options_form = GobiertoAdmin::GobiertoBudgets::OptionsForm.new(gobierto_budgets_params.merge(site: current_site))
        if @options_form.save
          flash[:notice] = t(".success")
        else
          flash[:alert] = t(".error", validation_errors: @options_form.errors.full_messages.to_sentence)
        end
        redirect_to admin_gobierto_budgets_options_path
      end

      def update_annual_data
        site = Site.find(current_site.id)
        ::GobiertoBudgets::GenerateAnnualLinesJob.perform_later(@site.object)
        flash[:notice] = t(".success")
        redirect_to admin_gobierto_budgets_options_path
      end

      private

      def gobierto_budgets_params
        params.require(:gobierto_budgets_options).permit(:elaboration_enabled, :budget_lines_feedback_enabled, :feedback_emails, :receipt_enabled, :receipt_configuration,
                                                         :comparison_tool_enabled, :comparison_context_table_enabled, :comparison_show_widget, :comparison_compare_municipalities_enabled,
                                                         :providers_enabled, :indicators_enabled, :budgets_guide_page,
                                                         comparison_compare_municipalities: [])
      end

      def get_services_config
        OpenStruct.new(APP_CONFIG["services"])
      end

      def get_available_pages
        @site.pages.active.sorted
      end
    end
  end
end
