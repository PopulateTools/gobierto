module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class PollAnswersController < Processes::BaseController

        helper_method :current_poll

        def index
          @poll_answers = current_poll.answers
        end

        private

        def current_poll
          @current_poll ||= current_process.polls.find(params[:poll_id])
        end
      end
    end
  end
end
