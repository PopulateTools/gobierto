# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ParticipationEventsIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:peter)
    end

    def participation_events_path
      @participation_events_path ||= gobierto_participation_events_path
    end

    def participation_current_events
      @participation_current_events ||= ::GobiertoCalendars::Event.in_collections_and_container_type(site, "GobiertoParticipation").published.upcoming
    end

    def participation_past_events
      @participation_past_events ||= ::GobiertoCalendars::Event.in_collections_and_container_type(site, "GobiertoParticipation").published.past
    end

    def test_secondary_nav
      with_current_site(site) do
        visit participation_events_path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_participation_events_index
      with_current_site(site) do
        visit participation_events_path

        assert_equal participation_current_events.size, all(".event-content").size

        assert has_link? "Swimming lessons for elders"
        assert has_link? "Intensive reading club in english"
      end
    end

    def test_participation_past_events_index
      with_current_site(site) do
        visit participation_events_path

        click_link "View past events"
        assert_equal participation_past_events.size, all(".event-content").size

        click_link "View current events"
        assert_equal participation_current_events.size, all(".event-content").size
      end
    end

    def test_participation_calendar_filter
      with_current_site(site) do
        visit gobierto_participation_events_path(date: participation_current_events.first.starts_at.to_date.to_s)

        refute_equal participation_current_events.size, all(".event-content").size
        assert has_link? "Swimming lessons for elders"
        assert has_link? "Innovation course"
        assert has_link? "View all events"
        assert has_link? "View past events"

        visit gobierto_participation_events_path(date: participation_current_events.second.starts_at.to_date.to_s)

        refute_equal participation_current_events.size, all(".event-content").size
        assert has_link? "Intensive reading club in english"
        assert has_link? "View all events"
        assert has_link? "View past events"
      end
    end
  end
end
