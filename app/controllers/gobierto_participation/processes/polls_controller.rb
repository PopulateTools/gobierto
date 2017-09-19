# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class PollsController < BaseController

      def index
        @polls = current_process.polls.answerable.order(ends_at: :asc)
      end

    end
  end
end
