module GobiertoAdmin
  class WelcomeController < BaseController
    def index
      @dashboard_data = retrieve_dashboard_data
    end

    private

    def retrieve_dashboard_data
      []
    end
  end
end
