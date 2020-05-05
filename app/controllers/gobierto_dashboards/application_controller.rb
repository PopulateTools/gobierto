# frozen_string_literal: true

class GobiertoDashboards::ApplicationController < ApplicationController
  include User::SessionHelper

  layout "gobierto_dashboards/layouts/application"

  before_action { module_enabled!(current_site, "GobiertoDashboards") }
end
