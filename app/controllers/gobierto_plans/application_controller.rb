# frozen_string_literal: true

module GobiertoPlans
  class ApplicationController < ::ApplicationController
    include User::SessionHelper

    layout "gobierto_plans/layouts/application"

    before_action { module_enabled!(current_site, "GobiertoPlans") }
  end
end
