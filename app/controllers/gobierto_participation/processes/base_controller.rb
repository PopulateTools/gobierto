module GobiertoParticipation
  module Processes
    class BaseController < GobiertoParticipation::ApplicationController

      helper_method :current_process

      protected

      def current_process
        @current_process ||= current_site.processes.find_by_slug!(params[:process_id])
      end

    end
  end
end
