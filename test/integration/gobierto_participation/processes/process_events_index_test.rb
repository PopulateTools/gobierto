# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessEventsIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def process_events_path
      @process_events_path ||= gobierto_participation_process_events_path(
        process_id: process.slug
      )
    end

    def user
      @user ||= users(:peter)
    end

    def process_current_events
      process.events.upcoming
    end

    def process_past_events
      process.events.past
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit process_events_path

        within "nav.main-nav" do
          assert has_link? "Participation"
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit process_events_path

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
        visit process_events_path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_subscription_block
      with_javascript do
        with_signed_in_user(user) do
          visit process_events_path

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

    def test_process_events_index
      process_current_events.first.update_attributes!(starts_at: Time.zone.now + 1.hour, ends_at: Time.zone.now)

      with_current_site(site) do
        visit process_events_path

        within ".events_list" do
          assert_equal process_current_events.size, all(".event-content").size

          assert has_content? "Intensive reading club in english"
          assert has_content? "Intensive reading club in english description"
        end
      end
    end

    def test_participation_past_events_index
      with_current_site(site) do
        visit process_events_path

        click_link "View past events"
        assert_equal process_past_events.size, all(".event-content").size

        click_link "View current events"
        assert_equal process_current_events.size, all(".event-content").size
      end
    end

    def test_process_event_show_see_all_events
      with_current_site(site) do
        visit process_events_path

        click_link "View all events"

        assert has_content? "Diary for Participation"

        assert has_link? "Innovation course"
        assert has_content? "Innovation course description"

        assert has_link? "Swimming lessons for elders"
        assert has_content? "Swimming lessons for elders description"

        assert has_link? "Intensive reading club in english"
        assert has_content? "Intensive reading club in english description"
      end
    end

    def test_process_calendar_filter
      with_current_site(site) do
        visit process_events_path + "?date=" + process_current_events.first.starts_at.to_date.to_s

        refute_equal process_current_events.size, all(".event-content").size
        assert has_link? "Intensive reading club in english"
        assert has_link? "View all events"
        assert has_link? "View past events"

        visit process_events_path + "?date=" + process_current_events.second.starts_at.to_date.to_s

        refute_equal process_current_events.size, all(".event-content").size
        assert has_link? "Swimming lessons for elders"
        assert has_link? "View all events"
        assert has_link? "View past events"
      end
    end
  end
end
