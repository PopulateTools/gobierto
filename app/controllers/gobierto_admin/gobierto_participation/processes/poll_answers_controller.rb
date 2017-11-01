module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class PollAnswersController < Processes::BaseController

        before_action { module_enabled!(current_site,  'GobiertoParticipation') }
        before_action { module_allowed!(current_admin, 'GobiertoParticipation') }

        helper_method :current_poll

        def index
          @poll_answers = current_poll.answers
        end

        private

        def current_poll
          @current_poll ||= current_process.polls.find(params[:poll_id])
        end

        def current_process
          @current_process ||= current_site.processes.find(params[:process_id])
        end

      end
    end
  end
end
