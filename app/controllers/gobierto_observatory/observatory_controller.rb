# frozen_string_literal: true

module GobiertoObservatory
  class ObservatoryController < GobiertoObservatory::ApplicationController
    include User::SessionHelper

    before_action :overrided_root_redirect

    def index; end
    def observatory_demography_map; end
  end
end
