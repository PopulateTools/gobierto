# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class IssueEventsIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def issue
      @issue ||= ProcessTermDecorator.new(gobierto_common_terms(:women_term))
    end

    def other_issue
      @other_issue ||= gobierto_common_terms(:economy_term)
    end

    def participation_process
      @participation_process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def issue_events_path
      @issue_events_path ||= gobierto_participation_issue_events_path(
        issue_id: issue.slug
      )
    end

    def user
      @user ||= users(:peter)
    end

    def issue_events
      issue.events
    end

    def test_menu_subsections
      with_current_site(site) do
        visit issue_events_path

        within "nav.sub-nav" do
          assert has_link? "Scopes"
          assert has_link? "Processes"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit issue_events_path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_issue_events_index
      issue_events.first.update_attributes!(starts_at: Time.zone.now + 1.hour, ends_at: Time.zone.now)

      with_current_site(site) do
        visit issue_events_path

        within ".events_list" do
          assert_equal issue_events.size, all(".event-content").size

          assert has_content? "Swimming lessons for elders"
          assert has_content? "Swimming lessons for elders description"

          assert has_content? "Intensive reading club in english"
          assert has_content? "Intensive reading club in english description"
        end
      end
    end

    def test_update_process_issue_events_index
      participation_process.update_attribute(:issue_id, other_issue.id)

      with_current_site(site) do
        visit issue_events_path

        assert has_content? "No related events"
      end
    end
  end
end
