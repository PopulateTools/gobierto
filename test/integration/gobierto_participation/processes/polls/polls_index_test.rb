# frozen_string_literal: true

require 'test_helper'

module GobiertoParticipation
  module Processes
    class PollsIndexTest < ActionDispatch::IntegrationTest

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:commission_for_carnival_festivities)
      end

      def process_polls_path
        @process_polls_path ||= gobierto_participation_process_polls_path(
          process_id: process.slug
        )
      end

      def process_polls
        @process_polls ||= process.polls
      end

      def test_process_polls_index
        with_current_site(site) do
          visit process_polls_path

          # published open polls apear
          assert has_content? 'Should the main street be pedestrianized?'
          assert has_content? 'General aspects of the ordinance'

          # draft, future and past polls are hidden
          refute has_content? 'Schedules'
          refute has_content? 'Public spaces'
          refute has_content? 'Noise'
        end
      end

    end
  end
end
