module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class BaseController < GobiertoAdmin::BaseController

        before_action { module_enabled!(current_site, "GobiertoParticipation") }
        before_action { module_allowed!(current_admin, "GobiertoParticipation") }

        helper_method :current_process

        protected

        def current_process
          @current_process ||= current_site.processes.find(params[:process_id])
        end
      end
    end
  end
end
