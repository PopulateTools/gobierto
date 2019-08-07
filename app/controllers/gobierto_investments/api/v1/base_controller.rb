# frozen_string_literal: true

module GobiertoInvestments
  module Api
    module V1
      class BaseController < ApiBaseController

        before_action { module_enabled!(current_site, "GobiertoInvestments", false) }

      end
    end
  end
end
