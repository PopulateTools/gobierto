# frozen_string_literal: true

module GobiertoObservatory
  class ApplicationController < ::ApplicationController
    layout "gobierto_observatory/layouts/application"

    before_action { module_enabled!(current_site, "GobiertoObservatory") }
  end
end
