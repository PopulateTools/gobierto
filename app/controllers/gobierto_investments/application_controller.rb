# frozen_string_literal: true

class GobiertoInvestments::ApplicationController < ApplicationController
  include User::SessionHelper

  layout "gobierto_investments/layouts/application"

  before_action { module_enabled!(current_site, "GobiertoInvestments") }
end
