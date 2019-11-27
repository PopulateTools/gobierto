# frozen_string_literal: true

class GobiertoData::ApplicationController < ApplicationController
  include User::SessionHelper

  layout "gobierto_data/layouts/application"
end
