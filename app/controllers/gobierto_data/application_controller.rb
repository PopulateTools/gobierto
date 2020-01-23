# frozen_string_literal: true

class GobiertoData::ApplicationController < ApplicationController
  include User::SessionHelper

  layout "gobierto_data/layouts/application"

  before_action { module_frontend_enabled!(current_site, "GobiertoData") }
end
