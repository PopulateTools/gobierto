# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessEventsShowTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def process_event
      @process_event ||= gobierto_calendars_events(:swimming_lessons)
    end

    def process_event_path
      @process_event_path ||= gobierto_participation_event_path(
        process_event.slug,
        container_type: process.container_type,
        container_id: process.id
      )
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit process_event_path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
          assert has_link? "Processes"
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit process_event_path

        within "menu.sub_sections" do
          assert has_link? "About"
          assert has_link? "Issues"
          assert has_link? "Processes"
          assert has_link? "Ask"
          assert has_link? "Ideas"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit process_event_path

        within "menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end

        # TODO: check that these links redirect to their corresponding pages
        # applying the right scope (single process/group scope)
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit process_event_path

        within ".site_header" do
          assert has_content? "Follow this process"
        end
      end
    end

    def test_process_event_show
      with_current_site(site) do
        visit process_event_path

        within ".event_wrapper" do
          assert has_content? "Swimming lessons for elders"
          assert has_link? "Instalaciones Deportivas Canal de Isabel II"
        end

        assert has_content? "Agenda"
        # TODO: refute has_content? "Agenda for #{process.title}"

        assert_equal process.events_in_collections.size, all(".has-events").size
      end
    end
  end
end
