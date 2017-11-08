module GobiertoAdmin
  module GobiertoBudgets
    class FeedbackController < BaseController
      before_action { module_enabled!(current_site,  'GobiertoBudgets') }
      before_action { module_allowed!(current_admin, 'GobiertoBudgets') }

      def index
        scope = ::GobiertoBudgets::BudgetLineFeedback.by_site(current_site)
        @total = scope.count
        @last_feedback = scope.newest
        @site_feedback = scope.all.group_by(&:year)
      end
    end
  end
end
