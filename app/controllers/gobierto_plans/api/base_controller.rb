# frozen_string_literal: true

module GobiertoPlans
  module Api
    class BaseController < ApiBaseController
      before_action { module_enabled!(current_site, "GobiertoPlans", false) }
    end
  end
end
