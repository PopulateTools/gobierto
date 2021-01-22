# frozen_string_literal: true

class GobiertoVisualizations::ApplicationController < ApplicationController
  include User::SessionHelper

  layout "gobierto_visualizations/layouts/application"

  before_action { module_enabled!(current_site, "GobiertoVisualizations") }
end
