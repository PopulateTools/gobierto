module GobiertoAdmin
  module GobiertoBudgets
    class OptionsController < BaseController
      before_action { module_enabled!(current_site,  'GobiertoBudgets') }
      before_action { module_allowed!(current_admin, 'GobiertoBudgets') }

      def index
        @options_form = GobiertoAdmin::GobiertoBudgets::OptionsForm.new
      end

      def update
        @options_form = GobiertoAdmin::GobiertoBudgets::OptionsForm.new
      end
    end
  end
end
