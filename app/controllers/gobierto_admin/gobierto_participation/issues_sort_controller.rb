module GobiertoAdmin
  module GobiertoParticipation
    class IssuesSortController < BaseController
      before_action { module_enabled!(current_site, "GobiertoParticipation") }
      before_action { module_allowed!(current_admin, "GobiertoParticipation") }

      def create
        ::GobiertoParticipation::Issue.update_positions(issue_sort_params)
        head :no_content
      end

      private

      def issue_sort_params
        params.require(:positions).permit!
      end
    end
  end
end
