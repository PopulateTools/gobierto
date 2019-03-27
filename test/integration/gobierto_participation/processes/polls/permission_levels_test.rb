# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  module Processes
    module Polls
      class PermissionLevelsTest < ActionDispatch::IntegrationTest

        def site
          @site ||= sites(:madrid)
        end

        def registered_level_user
          @registered_level_user ||= users(:janet)
        end

        def verified_level_user
          @verified_level_user ||= users(:peter)
        end

        def process
          @process ||= gobierto_participation_processes(:commission_for_carnival_festivities)
        end

        def process_polls_path
          @process_polls_path ||= gobierto_participation_process_polls_path(
            process_id: process.slug
          )
        end

        def registered_level_poll
          @registered_level_poll ||= gobierto_participation_polls(:ordinance_of_terraces_published)
        end

        def verified_level_poll
          @verified_level_poll ||= gobierto_participation_polls(:neighbor_opinion_poll)
        end

        def process_polls
          @process_polls ||= process.polls
        end

        def assert_both_levels_appear_in_index
          visit process_polls_path
          assert has_content? "General aspects of the ordinance"
          assert has_content? "What do the residents of the neighborhood think?"
        end

        def test_polls_not_registered_index
          with_current_site(site) do
            sign_out_user
            assert_both_levels_appear_in_index
          end
        end

        def test_polls_registered_index
          with_signed_in_user(registered_level_user) do
            assert_both_levels_appear_in_index
          end
        end

        def test_polls_verified_index
          with_signed_in_user(verified_level_user) do
            assert_both_levels_appear_in_index
          end
        end

        def test_polls_not_registered_tries_to_answer
          with_current_site(site) do
            visit process_polls_path
            within "#poll_#{registered_level_poll.id}" do
              click_link "Participate in this poll"
            end
            assert has_no_content? "Do you think that the ordinance should be modified?"

            visit process_polls_path
            within "#poll_#{verified_level_poll.id}" do
              click_link "Participate in this poll"
            end
            assert has_no_content? "Do you mind if the carnival parade takes place next to your house?"
          end
        end

        def test_polls_registered_level_tries_to_answer
          with_signed_in_user(registered_level_user) do
            visit process_polls_path
            within "#poll_#{registered_level_poll.id}" do
              click_link "Participate in this poll"
            end
            assert has_content? "Do you think that the ordinance should be modified?"

            visit process_polls_path
            within "#poll_#{verified_level_poll.id}" do
              click_link "Participate in this poll"
            end
            assert has_no_content? "Do you mind if the carnival parade takes place next to your house?"
          end
        end

        def test_polls_verified_tries_to_answer
          with_signed_in_user(verified_level_user) do
            visit process_polls_path
            within "#poll_#{registered_level_poll.id}" do
              click_link "Participate in this poll"
            end
            assert has_content? "Do you think that the ordinance should be modified?"

            visit process_polls_path
            within "#poll_#{verified_level_poll.id}" do
              click_link "Participate in this poll"
            end
            assert has_content? "Do you mind if the carnival parade takes place next to your house?"
          end
        end

      end
    end
  end
end
