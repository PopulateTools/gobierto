# frozen_string_literal: true

module GobiertoAdmin
  class ScopesSortController < BaseController
    def create
      current_site.scopes.update_positions(scope_sort_params)
      head :no_content
    end

    private

    def scope_sort_params
      params.require(:positions).permit!
    end
  end
end
