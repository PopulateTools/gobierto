# frozen_string_literal: true

module GobiertoParticipation
  module Issues
    class BaseController < GobiertoParticipation::ApplicationController
      helper_method :current_process

      protected

      def current_process
        issue = Issue.find_by_slug!(params[:issue_id])
        @current_process ||= processes_scope.find_by(issue: issue)
      end

      private

      def processes_scope
        valid_preview_token? ? current_site.processes : current_site.processes.active
      end
    end
  end
end
