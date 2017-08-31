# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessContributionContainersShowTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def process
      @process ||= gobierto_participation_processes(:sport_city_process)
    end

    def contribution_container
      @contribution_container ||= gobierto_participation_contribution_containers(:children_contributions)
    end

    def container_path
      @container_path ||= gobierto_participation_process_process_contribution_container_path(
        process_id: process.slug,
        id: contribution_container.slug
      )
    end

    def contributions
      @contributions ||= contribution_container.contributions
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit container_path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
          assert has_link? "Processes"
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit container_path

        within "menu.sub_sections" do
          assert has_link? "Information"
          assert has_link? "Meetings"
          assert has_link? "Polls"
          assert has_link? "Contributions"
          assert has_link? "Results"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit container_path

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
        visit container_path

        within ".site_header" do
          assert has_content? "Follow this process"
        end
      end
    end

    def test_contributions_show
      with_current_site(site) do
        visit container_path

        # TODO: Pending bug n contributions - 1
        skip "Not yet defined"
        # assert_equal process_contribution_containers.size, all(".card").size
        # assert has_link? "Cine de verano en el Juan Carlos I"
        # assert has_link? "Carril bici hasta el Juan Carlos I"
      end
    end
  end
end
