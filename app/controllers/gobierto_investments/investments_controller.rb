# frozen_string_literal: true

module GobiertoInvestments
  class InvestmentsController < GobiertoInvestments::ApplicationController
    def index; end
    def tour
      render action: "index"
    end
  end
end
