# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ScopeEventsIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def scope
      @scope ||= ProcessTermDecorator.new(gobierto_common_terms(:old_town_term))
    end

    def other_scope
      @other_scope ||= gobierto_common_terms(:center_term)
    end

    def participation_process
      @participation_process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def scope_events_path
      @scope_events_path ||= gobierto_participation_scope_events_path(
        scope_id: scope.slug
      )
    end

    def user
      @user ||= users(:peter)
    end

    def scope_events
      scope.events
    end

    def test_menu_subsections
      with_current_site(site) do
        visit scope_events_path

        within "nav.sub-nav" do
          assert has_link? "Scopes"
          assert has_link? "Processes"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit scope_events_path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_scope_events_index
      scope_events.first.update_attributes!(starts_at: Time.zone.now + 1.hour, ends_at: Time.zone.now)

      with_current_site(site) do
        visit scope_events_path

        within ".events_list" do
          assert_equal scope_events.size, all(".event-content").size

          assert has_content? "Swimming lessons for elders"
          assert has_content? "Swimming lessons for elders description"

          assert has_content? "Intensive reading club in english"
          assert has_content? "Intensive reading club in english description"
        end
      end
    end

    def test_update_process_scope_events_index
      participation_process.update_attribute(:scope_id, other_scope.id)

      with_current_site(site) do
        visit scope_events_path

        assert has_content? "No related events"
      end
    end
  end
end
