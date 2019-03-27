# frozen_string_literal: true

module GobiertoExports
  class ExportsController < GobiertoExports::ApplicationController
    include User::SessionHelper

    def index
    end
  end
end
