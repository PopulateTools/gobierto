# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ParticipationEventsShowTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:peter)
    end

    def participation_event
      @participation_event ||= gobierto_calendars_events(:innovation_event)
    end

    def participation_event_path
      @participation_event_path ||= gobierto_participation_event_path(participation_event.slug)
    end

    def test_secondary_nav
      with_current_site(site) do
        visit participation_event_path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_participation_event_show_without_documents
      with_current_site(site) do
        visit participation_event_path

        assert has_content? "Innovation course"

        within ".person_event-item" do
          refute has_content? "Documents"
        end
      end
    end
  end
end
