# frozen_string_literal: true

module GobiertoObservatory
  class ObservatoryController < GobiertoObservatory::ApplicationController
    include User::SessionHelper

    def index
    end
  end
end
