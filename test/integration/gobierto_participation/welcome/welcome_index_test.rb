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

    def test_breadcrumb_items
      with_current_site(site) do
        visit @path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit @path

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
        visit @path

        within "menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Diary"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_secondary_nav_news
      with_current_site(site) do
        visit @path

        click_link "News"

        assert_equal gobierto_participation_pages_path, current_path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
        end

        assert has_selector?("h2", text: "News")
      end
    end

    def test_secondary_nav_diary
      with_current_site(site) do
        visit @path

        click_link "Diary"

        assert_equal gobierto_participation_events_path, current_path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
        end

        assert has_link? "View all events"
      end
    end

    def test_secondary_nav_documents
      with_current_site(site) do
        visit @path

        click_link "Documents"

        assert_equal gobierto_participation_attachments_path, current_path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
        end

        assert has_selector?("h2", text: "Documents")
      end
    end

    def test_secondary_nav_activity
      with_current_site(site) do
        visit @path

        click_link "Activity"

        assert_equal gobierto_participation_activities_path, current_path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
        end

        assert has_selector?("h2", text: "Updates")
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit @path

        within ".site_header" do
          skip "Not yet defined"
        end
      end
    end
  end
end
