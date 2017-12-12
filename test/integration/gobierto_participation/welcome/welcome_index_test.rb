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

    def test_breadcrumb_items
      with_current_site(site) do
        visit @path

        within ".main-nav" do
          assert has_link? "Participation"
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit @path

        within ".sub-nav" do
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
          assert has_link? "Agenda"
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

        within ".main-nav" do
          assert has_link? "Participation"
        end

        assert has_selector?("h2", text: "News")
      end
    end

    def test_secondary_nav_diary
      with_current_site(site) do
        visit @path

        click_link "Agenda"

        assert_equal gobierto_participation_events_path, current_path

        within ".main-nav" do
          assert has_link? "Participation"
        end
      end
    end

    def test_secondary_nav_documents
      with_current_site(site) do
        visit @path

        click_link "Documents"

        assert_equal gobierto_participation_attachments_path, current_path

        within ".main-nav" do
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

        within ".main-nav" do
          assert has_link? "Participation"
        end

        assert has_selector?("h2", text: "Updates")
      end
    end

    def test_show_poll
      with_javascript do
        with_current_site(site) do
          with_signed_in_user(user) do
            visit @path

            assert has_content? poll.questions.first.title
          end
        end
      end
    end

    def test_welcome_index_template
      with_current_site(site) do
        visit @path

        assert has_content?("My Template")
        refute has_content?("Ongoing processes")
        refute has_content?("Themes")
      end
    end
  end
end
