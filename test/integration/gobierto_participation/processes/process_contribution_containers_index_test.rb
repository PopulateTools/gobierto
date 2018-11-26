# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessContributionContainersIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def process
      @process ||= gobierto_participation_processes(:bowling_group_very_active)
    end

    def process_contribution_containers_path
      @process_contribution_containers_path ||= gobierto_participation_process_contribution_containers_path(
        process_id: process.slug
      )
    end

    def process_contribution_containers
      @process_contribution_containers ||= process.contribution_containers
    end

    def current_container
      @current_container ||= gobierto_participation_contribution_containers(:bowling_group_contributions_current)
    end

    def future_container
      @future_container ||= gobierto_participation_contribution_containers(:bowling_group_contributions_future)
    end

    def past_container
      @past_container ||= gobierto_participation_contribution_containers(:bowling_group_contributions_past)
    end

    def draft_container
      @draft_container ||= gobierto_participation_contribution_containers(:bowling_group_contributions_future_draft)
    end

    def contribution_container_wrapper(container)
      container_path = gobierto_participation_process_contribution_container_path(
        container.slug,
        process_id: container.process.slug
      )
      find(:xpath, "//a[@href='#{container_path}']")
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit process_contribution_containers_path

        within "nav.main-nav" do
          assert has_link? "Participation"
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit process_contribution_containers_path

        menu_items = process.stages.map(&:menu)

        within "nav.sub-nav" do
          menu_items.each do |menu_item|
            assert has_link? menu_item
          end
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit process_contribution_containers_path

        within "nav.sub-nav menu.secondary_nav" do
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

        within ".slim_nav_bar" do
          assert has_content? "Follow group"
        end
      end
    end

    def test_process_contribution_containers_index
      with_current_site(site) do
        visit process_contribution_containers_path

        assert_equal process_contribution_containers.active.size, all(".themed").size

        assert has_no_content? draft_container.title

        within contribution_container_wrapper(current_container) do
          assert has_content? 'What can we do to improve the bowling group?'
          assert has_content? 'This is the container description'

          assert has_content? current_container.comments_count
          assert has_content? current_container.participants_count
        end

        within contribution_container_wrapper(future_container) do
          assert has_content? 'This container has not started'
          assert has_content? 'The contributions period starts on'
        end

        within contribution_container_wrapper(past_container) do
          assert has_content? 'This container has already finished'
          assert has_content? 'The contributions period has ended'
        end
      end
    end
  end
end
