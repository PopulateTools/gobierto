# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    module Api
      class BaseController < GobiertoAdmin::Api::BaseController
        before_action { module_enabled!(current_site, "GobiertoPlans") }
        before_action { module_allowed!(current_admin, "GobiertoPlans") }
      end
    end
  end
end
