# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class WelcomeIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_participation_root_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:peter)
    end

    def poll
      @poll ||= gobierto_participation_polls(:ordinance_of_terraces_published)
    end

    def issues
      @issues ||= Process.issues(site).sorted
    end

    def processes
      @processes ||= site.processes.process.active
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit @path

        within "nav.main-nav" do
          assert has_link? "Participation"
        end
      end
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

        assert_equal gobierto_participation_news_index_path, current_path

        within "nav.main-nav" do
          assert has_link? "Participation"
        end

        assert has_selector?("h2", text: "News")
      end
    end

    def test_secondary_nav_diary
      with_current_site(site) do
        visit @path

        within "nav.sub-nav menu.secondary_nav" do
          click_link "Agenda"
        end

        assert_equal gobierto_participation_events_path, current_path

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

        assert_equal gobierto_participation_attachments_path, current_path

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

        assert_equal gobierto_participation_activities_path, current_path

        within "nav.main-nav" do
          assert has_link? "Participation"
        end

        assert has_selector?("h2", text: "Updates")
      end
    end

    def test_show_poll
      with_javascript do
        with_signed_in_user(user) do
          visit @path

          assert has_link? poll.title
          assert has_content? poll.questions.first.title
        end
      end
    end

    def test_welcome_index_template
      with_current_site(site) do
        visit @path

        assert has_content?("My Template")

        assert has_content?("Paritipation Agenda")
        assert has_content?("The last")
        assert has_content?("News")

        assert has_content?("Themes")
        issues.each do |issue|
          assert has_link?(issue.name)
        end

        assert has_content?("Processes in progress")
        processes.each do |process|
          assert has_link?(process.title)
        end
      end
    end
  end
end
