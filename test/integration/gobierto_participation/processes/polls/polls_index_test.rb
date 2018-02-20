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

      def poll
        @poll ||= gobierto_participation_polls(:ordinance_of_terraces_published)
      end

      def process_polls
        @process_polls ||= process.polls
      end

      def user_already_answered
        @user_already_answered ||= users(:dennis)
      end

      def test_process_polls_index
        with_current_site(site) do
          visit process_polls_path

          # published open polls apear
          assert has_content? 'What do the residents of the neighborhood think?'
          assert has_content? 'General aspects of the ordinance'

          # draft, future and past polls are hidden
          assert has_no_content? 'Schedules'
          assert has_no_content? 'Public spaces'
          assert has_no_content? 'Noise'
        end
      end

      def test_disable_participate_link_for_already_answered_polls
        with_signed_in_user(user_already_answered) do

          visit process_polls_path

          within "#poll_#{poll.id}" do
            assert has_content? 'You have already participated in this poll'
            assert has_no_content? 'Participate in this poll'
          end

        end
      end

    end
  end
end
