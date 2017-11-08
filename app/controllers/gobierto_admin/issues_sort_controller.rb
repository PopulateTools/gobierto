# frozen_string_literal: true

module GobiertoAdmin
  class IssuesSortController < BaseController
    def create
      current_site.issues.update_positions(issue_sort_params)
      head :no_content
    end

    private

    def issue_sort_params
      params.require(:positions).permit!
    end
  end
end
