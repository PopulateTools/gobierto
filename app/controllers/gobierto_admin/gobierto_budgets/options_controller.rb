module GobiertoAdmin
  module GobiertoBudgets
    class OptionsController < BaseController
      before_action { module_enabled!(current_site,  'GobiertoBudgets') }
      before_action { module_allowed!(current_admin, 'GobiertoBudgets') }

      def index
        @options_form = GobiertoAdmin::GobiertoBudgets::OptionsForm.new(site: current_site)
      end

      def update
        @options_form = GobiertoAdmin::GobiertoBudgets::OptionsForm.new(gobierto_budgets_params.merge(site: current_site))
        if @options_form.save
          flash[:notice] = t(".success")
        else
          flash[:alert] = t(".error", validation_errors: @options_form.errors.full_messages.to_sentence)
        end
        redirect_to admin_gobierto_budgets_options_path
      end

      private

      def gobierto_budgets_params
        params.require(:gobierto_budgets_options).permit(:elaboration_enabled, :budget_lines_feedback_enabled, :feedback_emails, :receipt_enabled, :receipt_configuration)
      end
    end
  end
end
