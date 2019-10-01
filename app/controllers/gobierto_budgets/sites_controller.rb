module GobiertoBudgets
  class SitesController < GobiertoBudgets::ApplicationController

    def show
      redirect_to GobiertoBudgets.root_path(current_site)
    end
  end
end
