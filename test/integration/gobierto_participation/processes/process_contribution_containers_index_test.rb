# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessContributionContainersIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def process
      @process ||= gobierto_participation_processes(:sport_city_process)
    end

    def process_contribution_containers_path
      @process_contribution_containers_path ||= gobierto_participation_process_process_contribution_containers_path(
        process_id: process.slug
      )
    end

    def process_contribution_containers
      @process_contribution_containers ||= process.contribution_containers
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit process_contribution_containers_path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
          assert has_link? "Processes"
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        processes.each do |process|
          visit process_path(process)

          within 'menu.sub_sections' do
            assert has_link? 'Information'
            assert has_link? 'Meetings'

            if process.polls_stage?
              assert has_link? 'Polls'
            else
              refute has_link? 'Polls'
            end

            assert has_link? 'Contributions'
            assert has_link? 'Results'
          end
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit process_contribution_containers_path

        within "menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit process_contribution_containers_path

        within ".site_header" do
          assert has_content? "Follow this process"
        end
      end
    end

    def test_process_contribution_containers_index
      with_current_site(site) do
        visit process_contribution_containers_path

        assert_equal process_contribution_containers.size, all(".themed").size
        assert has_content? "Ideas for activities for children"
        assert has_link? "What activities for children we can start up?"
      end
    end
  end
end
