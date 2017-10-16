# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class BaseController < GobiertoParticipation::ApplicationController
      include ::PreviewTokenHelper
      include ProcessStagesHelper

      helper_method :current_process

      protected

      def current_process
        @current_process ||= processes_scope.find_by_slug!(params[:process_id])
      end

      private

      def processes_scope
        valid_preview_token? ? current_site.processes : current_site.processes.active
      end
    end
  end
end
