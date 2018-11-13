# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class IssueShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_participation_issue_path(:women)
    end

    def user
      @user ||= users(:peter)
    end

    def site
      @site ||= sites(:madrid)
    end

    def issue
      @issue ||= ProcessTermDecorator.new(gobierto_common_terms(:women_term))
    end

    def processes
      @processes ||= site.processes.process.where(issue: issue).active
    end

    def groups
      @groups ||= site.processes.group_process.where(issue: issue)
    end

    def test_menu_subsections
      with_current_site(site) do
        visit @path

        within "nav.sub-nav" do
          assert has_link? "Scopes"
          assert has_link? "Processes"
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

        assert has_selector?("h2", text: "News for Women")
      end
    end

    def test_secondary_nav_diary
      with_current_site(site) do
        visit @path

        within "nav.sub-nav menu.secondary_nav" do
          click_link "Agenda"
        end

        assert_equal gobierto_participation_issue_events_path(issue_id: issue.slug), current_path

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

        assert_equal gobierto_participation_issue_attachments_path(issue_id: issue.slug), current_path

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

        assert_equal gobierto_participation_issue_activities_path(issue_id: issue.slug), current_path

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
            assert has_link? "Follow theme"
          end

          click_on "Follow theme"
          assert has_link? "Theme followed!"

          click_on "Theme followed!"
          assert has_link? "Follow theme"
        end
      end
    end

    def test_issue
      with_current_site(site) do
        visit @path

        within ".container" do
          assert has_content? issue.name
          assert has_content? issue.description
        end
      end
    end

    def test_process_news
      with_current_site(site) do
        visit @path

        assert_equal issue.active_news.size, all(".place_news-item").size
      end
    end

    def test_issue_with_events
      with_current_site(site) do
        visit @path

        assert_equal issue.events.upcoming.size, all(".event-content").size
      end
    end

    def test_issue_processes
      with_current_site(site) do
        visit @path

        assert_equal processes.size, all("div#processes/div").size
      end
    end
  end
end
