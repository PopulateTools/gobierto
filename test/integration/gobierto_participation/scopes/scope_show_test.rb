# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ScopeShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_participation_scope_path(scope_center.slug)
    end

    def user
      @user ||= users(:peter)
    end

    def site
      @site ||= sites(:madrid)
    end

    def scope_center
      @scope_center ||= ProcessTermDecorator.new(gobierto_common_terms(:center_term))
    end

    def other_scope
      @other_scope ||= gobierto_common_terms(:old_town_term)
    end

    def participation_process
      @participation_process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def processes
      @processes ||= site.processes.process.where(scope: scope_center).active
    end

    def groups
      @groups ||= site.processes.group_process.where(scope: scope_center)
    end

    def scope_notifications
      @scope_notifications ||= site.activities.no_admin.in_process(processes)
    end

    def scope_notifications_titles_match
      @scope_notifications_titles_match ||= Regexp.new("Contribution created")
    end

    def test_menu_subsections
      with_current_site(site) do
        visit @path

        within "nav.sub-nav" do
          assert has_content? "Scopes"
          assert has_content? "Processes"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit @path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_secondary_nav_news
      with_current_site(site) do
        visit @path

        within "nav.sub-nav menu.secondary_nav" do
          click_link "News"
        end

        within "nav.main-nav" do
          assert has_link? "Participation"
        end

        assert has_selector?("h2", text: "News for Center")
      end
    end

    def test_secondary_nav_diary
      with_current_site(site) do
        visit @path

        within "nav.sub-nav menu.secondary_nav" do
          click_link "Agenda"
        end

        assert_equal gobierto_participation_scope_events_path(scope_id: scope_center.slug), current_path

        within "nav.main-nav" do
          assert has_link? "Participation"
        end
      end
    end

    def test_secondary_nav_documents
      with_current_site(site) do
        visit @path

        within "nav.sub-nav menu.secondary_nav" do
          click_link "Documents"
        end

        assert_equal gobierto_participation_scope_attachments_path(scope_id: scope_center.slug), current_path

        within "nav.main-nav" do
          assert has_link? "Participation"
        end

        assert has_selector?("h2", text: "Documents")
      end
    end

    def test_secondary_nav_activity
      with_current_site(site) do
        visit @path

        within "nav.sub-nav menu.secondary_nav" do
          click_link "Activity"
        end

        assert_equal gobierto_participation_scope_activities_path(scope_id: scope_center.slug), current_path

        within "nav.main-nav" do
          assert has_link? "Participation"
        end

        assert has_selector?("h2", text: "Updates")
      end
    end

    def test_subscription_block
      with_javascript do
        with_signed_in_user(user) do
          visit @path

          within ".slim_nav_bar" do
            assert has_link? "Follow scope"
          end

          click_on "Follow scope"
          assert has_link? "Scope followed!"

          click_on "Scope followed!"
          assert has_link? "Follow scope"
        end
      end
    end

    def test_process_news
      with_current_site(site) do
        visit @path

        assert_equal scope_center.active_news.size, all(".place_news-item").size
      end
    end

    def test_scope_with_events
      with_current_site(site) do
        visit @path

        assert_equal scope_center.events.size, all(".place_events-item").size
      end
    end

    def test_scope_with_notifications
      with_current_site(site) do
        visit @path

        assert_operator all(".place_latest-item").size, :<=, 5
        all(".place_latest-item").each do |element|
          assert_match scope_notifications_titles_match, element.text
        end
      end
    end

    def test_scope_processes
      with_current_site(site) do
        visit @path

        within "div#processes" do
          refute has_content? participation_process.title
        end

        assert_equal processes.size, all("div#processes/div").size
      end
    end

    def test_update_process_scope_show
      participation_process.update_attribute(:scope_id, scope_center.id)

      with_current_site(site) do
        visit @path

        within "div#processes" do
          assert has_content? participation_process.title
        end
        participation_process.news.each do |page|
          assert has_link? page.title
        end
        participation_process.events.published.upcoming.each do |event|
          assert has_link? event.title
        end
        refute has_content? "No related updates"
      end
    end

  end
end
