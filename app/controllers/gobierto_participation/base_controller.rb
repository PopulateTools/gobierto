# frozen_string_literal: true

module GobiertoParticipation
  class BaseController < GobiertoParticipation::ApplicationController
    helper_method :current_process

    protected

    def current_process
      @current_process = nil
    end
  end
end
