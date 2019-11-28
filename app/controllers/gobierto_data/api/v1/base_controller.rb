# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class BaseController < ApiBaseController

        before_action { module_enabled!(current_site, "GobiertoData", false) }

      end
    end
  end
end
