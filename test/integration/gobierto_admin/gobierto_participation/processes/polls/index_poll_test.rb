# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class IndexPollTest < ActionDispatch::IntegrationTest

      def setup
        super
        @path = admin_participation_process_polls_path(process)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:commission_for_carnival_festivities)
      end

      def polls
        @polls ||= process.polls
      end

      def poll
        @poll ||= gobierto_participation_polls(:ordinance_of_terraces_published)
      end

      def test_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "table" do
              assert_equal polls.size, (all("tr").size - 1)

              polls.each do |poll|
                within "#poll-item-#{poll.id}" do
                  assert has_content? poll.title
                  assert has_content? poll.unique_answers_count
                  assert has_content? poll.visibility_level.capitalize
                  assert has_link? "View poll"
                end
              end
            end
          end
        end
      end

    end
  end
end
