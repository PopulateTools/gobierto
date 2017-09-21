# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class PollsController < BaseController

      before_action { check_active_stage(current_process, ProcessStage.stage_types[:polls]) }

      def index
        @polls = current_process.polls.answerable.order(ends_at: :asc)
      end

    end
  end
end
