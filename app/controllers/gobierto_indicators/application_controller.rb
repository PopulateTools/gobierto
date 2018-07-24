# frozen_string_literal: true

module GobiertoIndicators
  class ApplicationController < ::ApplicationController
    layout "gobierto_indicators/layouts/application"

    before_action { gobierto_module_enabled!(current_site, "GobiertoIndicators") }
  end
end
