module GobiertoIndicators
  class ApplicationController < ::ApplicationController
    layout "gobierto_indicators/layouts/application"

    before_action { module_enabled!(current_site, "GobiertoIndicators") }
  end
end
