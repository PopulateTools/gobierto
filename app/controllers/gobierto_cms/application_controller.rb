# frozen_string_literal: true

module GobiertoCms
  class ApplicationController < ::ApplicationController
    include User::SessionHelper
    include ::PreviewTokenHelper

    DEFAULT_LAYOUT = "gobierto_cms/layouts/application"

    layout :pick_layout

    before_render :set_current_module

    # FIXME
    helper_method :current_process

    private

    # FIXME
    def current_process
      @current_process
    end

    protected

    def set_current_module
      return if @collection.nil?

      if params[:process_id]
        @current_module = "gobierto_participation"
      else
        case @collection.container_type
          when "GobiertoParticipation"
            @current_module = "gobierto_participation"
          when "GobiertoParticipation::Process"
            @current_module = "gobierto_participation"
            @current_process ||= @collection.container
        end
      end
    end

    def pick_layout
      return DEFAULT_LAYOUT if @collection.nil?

      case (@page ? @page.context : @collection.container_type)
        when "GobiertoParticipation"
          "gobierto_participation/layouts/application"
        when "GobiertoParticipation::Process"
          "gobierto_participation/layouts/application"
        else
          DEFAULT_LAYOUT
      end
    end
  end
end
