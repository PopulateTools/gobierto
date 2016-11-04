module GobiertoBudgets
  class SitesController < GobiertoBudgets::ApplicationController
    def show
      redirect_to gobierto_budgets_budgets_path(GobiertoBudgets::SearchEngineConfiguration::Year.last)
    end
  end
end
