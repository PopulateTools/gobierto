# frozen_string_literal: true

require "#{Rails.root}/app/models/gobierto_data"

class GobiertoData::ApplicationController < ApplicationController
  include User::SessionHelper

  layout "gobierto_data/layouts/application"

  before_action { module_frontend_enabled!(current_site, "GobiertoData") }
end
