module GobiertoBudgets
  class SitesController < GobiertoBudgets::ApplicationController
    def show
      if budgets_elaboration_active?
        redirect_to gobierto_budgets_budgets_elaboration_path
      else
        redirect_to gobierto_budgets_budgets_path(GobiertoBudgets::SearchEngineConfiguration::Year.last)
      end
    end
  end
end
