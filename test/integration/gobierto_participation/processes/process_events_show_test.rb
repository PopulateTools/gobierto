# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessEventsShowTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:peter)
    end

    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def process_event
      @process_event ||= gobierto_calendars_events(:reading_club)
    end

    def process_event_path
      @process_event_path ||= gobierto_participation_process_event_path(
        process_event.slug,
        process_id: process.slug
      )
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit process_event_path

        within "nav.main-nav" do
          assert has_link? "Participation"
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit process_event_path

        within "nav.sub-nav" do
          assert has_link? "Information"
          assert has_link? "Agenda"

          assert has_no_link? "Polls"
          assert has_no_link? "Contributions"
          assert has_no_link? "Results"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit process_event_path

        within "nav.sub-nav menu.secondary_nav" do
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
      with(js: true) do
        with_signed_in_user(user) do
          visit process_event_path

          within ".slim_nav_bar" do
            assert has_link? "Follow process"
          end

          click_on "Follow process"
          assert has_link? "Process followed!"

          click_on "Process followed!"
          assert has_link? "Follow process"
        end
      end
    end

    def test_process_event_show
      with_current_site(site) do
        visit process_event_path

        within ".event_wrapper" do
          assert has_content? "Intensive reading club in english"
          assert has_content? "Intensive reading club in english description"

          within ".document" do
            assert has_content? "XLSX Attachment Event"
          end
        end

        assert has_content? "Agenda"
        # TODO: assert has_no_content? "Agenda for #{process.title}"
      end
    end

    def test_process_event_show_see_all_events
      with_current_site(site) do
        visit process_event_path

        click_link "View all events"

        assert_equal process.events.upcoming.size, all(".event-content").size
      end
    end
  end
end
