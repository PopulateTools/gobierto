# frozen_string_literal: true

module GobiertoIndicators
  class IndicatorsController < GobiertoIndicators::ApplicationController
    include User::SessionHelper

    def index; end
  end
end
