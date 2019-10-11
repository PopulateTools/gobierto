# frozen_string_literal: true

module GobiertoInvestments
  class InvestmentsController < GobiertoInvestments::ApplicationController
    def index; end
    def tour
      render "tour", layout: "minimal"
     end
  end
end
