# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessShowTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:peter)
    end

    def process_path(process)
      @process_path ||= gobierto_participation_process_path(process.slug)
    end

    def gender_violence_process
      @gender_violence_process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def commission_for_carnival_festivities
      @commission_for_carnival_festivities ||= gobierto_participation_processes(:commission_for_carnival_festivities)
    end

    def processes
      @processes ||= [gender_violence_process, commission_for_carnival_festivities]
    end

    def green_city_group
      @green_city_group ||= gobierto_participation_processes(:green_city_group_active_empty)
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit process_path(gender_violence_process)

        within "nav.main-nav" do
          assert has_link? "Participation"
          assert has_link? gender_violence_process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        processes.each do |process|
          visit process_path(process)

          within "nav.sub-nav" do
            assert has_link? "Information"
            assert has_link? "Agenda"
            assert has_no_link? "Ideas"
            assert has_no_link? "Polls"
          end
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit process_path(gender_violence_process)

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
        visit process_path(gender_violence_process)

        within "nav.main-nav" do
          assert has_link? "Participation"
          assert has_link? gender_violence_process.title
        end

        within "nav.sub-nav menu.secondary_nav" do
          click_link "News"
        end

        assert_equal gobierto_participation_process_news_index_path(process_id: gender_violence_process.slug), current_path

        assert has_selector?("h2", text: "News")
      end
    end

    def test_secondary_nav_diary
      with_current_site(site) do
        visit process_path(gender_violence_process)

        within "nav.sub-nav menu.secondary_nav" do
          click_link "Agenda"
        end

        assert_equal gobierto_participation_process_events_path(process_id: gender_violence_process.slug), current_path
      end
    end

    def test_secondary_nav_documents
      with_current_site(site) do
        visit process_path(gender_violence_process)

        within "nav.sub-nav menu.secondary_nav" do
          click_link "Documents"
        end

        assert_equal gobierto_participation_process_attachments_path(process_id: gender_violence_process.slug), current_path

        assert has_selector?("h2", text: "Documents")
      end
    end

    def test_secondary_nav_activity
      with_current_site(site) do
        visit process_path(gender_violence_process)

        within "nav.sub-nav menu.secondary_nav" do
          click_link "Activity"
        end

        assert_equal gobierto_participation_process_activities_path(process_id: gender_violence_process.slug), current_path

        assert has_selector?("h2", text: "Updates")
      end
    end

    def test_subscription_block
      with_javascript do
        with_signed_in_user(user) do
          visit process_path(gender_violence_process)
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

    def test_site_subscription
      with_signed_in_user(user) do

        visit process_path(gender_violence_process)
        within ".slim_nav_bar" do
          assert has_link? "Follow process"
        end

        within "footer" do
          click_on "Subscribe"
        end

        assert has_content? "Process followed!"
        assert has_link? "Manage your alerts"

      end
    end

    def test_process
      with_current_site(site) do
        visit process_path(gender_violence_process)

        within ".container" do
          assert has_content? gender_violence_process.title
          assert has_content? gender_violence_process.body

          assert has_content? "Interesting information"

          process_duration_text = "#{gender_violence_process.starts.strftime("%-e/%m/%y")} to #{gender_violence_process.ends.strftime("%-e/%m/%y")}"

          assert has_content? process_duration_text
          assert has_content? "Women"
          assert has_content? "Old town"
        end
      end
    end

    def test_process_news
      with_current_site(site) do
        visit process_path(gender_violence_process)

        assert_equal gender_violence_process.news.size, all(".place_news-item").size

        news_titles = gender_violence_process.news.map(&:title)

        assert array_match ["Notice 1 title", "Notice 2 title"], news_titles
      end
    end

    def test_process_without_news
      with_current_site(site) do
        visit gobierto_participation_process_path(green_city_group.slug)

        assert has_content? "There are no related news"
      end
    end

    def test_process_events
      with_current_site(site) do
        visit process_path(gender_violence_process)

        assert_equal gender_violence_process.events.size, all(".place_event-item").size

        events_titles = gender_violence_process.events.map(&:title)

        assert array_match ["Intensive reading club in english", "Swimming lessons for elders", "Talk intervention with children"], events_titles
      end
    end

    def test_process_without_events
      with_current_site(site) do
        visit gobierto_participation_process_path(green_city_group.slug)

        assert has_content? "No related events"
      end
    end

    def test_process_activities
      with_current_site(site) do
        visit process_path(gender_violence_process)

        assert has_content? "No related updates"
      end
    end

    def test_process_stages
      with_current_site(site) do
        visit process_path(gender_violence_process)

        within ".timeline" do
          assert_equal gender_violence_process.published_stages.size, all(".timeline_row").size
        end
      end
    end

    def test_process_without_stages
      with_current_site(site) do
        visit gobierto_participation_process_path(green_city_group.slug)

        assert has_no_content? "Process stages"
      end
    end

    def test_progress_map_with_many_published_stages
      published_stages = gender_violence_process.published_stages

      with_current_site(site) do
        visit process_path(gender_violence_process)

        within "#progress_map" do
          # current stage title and CTA, and a dot for each active stage
          assert has_content? "Current stage"
          assert_equal published_stages.size, all(".dot").size

          # check current stage is marked, and upcoming stages dots are grayed out
          assert has_selector?("##{gender_violence_process.current_stage.slug}_stage_dot > .dot-current")
          assert_equal published_stages.upcoming.size, all(".dot.disabled").size
        end
      end
    end

    def test_progress_map_with_one_active_stage
      with_current_site(site) do
        visit process_path(commission_for_carnival_festivities)

        within "#progress_map" do
          # just title  and CTA of current stage
          assert has_content? "Current stage"
          assert has_link? "Participate"
          assert has_no_selector? ".dots-container"
        end
      end
    end

    def test_progress_map_with_no_published_stages
      with_current_site(site) do
        visit process_path(green_city_group)

        # hide progress map
        assert has_no_selector? "#progress_map"
      end
    end

    def test_process_information_stage
      with_current_site(site) do
        visit process_path(gender_violence_process)

        page.all("a", text: "Information").first.click

        assert has_selector?("h1", text: "Privacy")
      end
    end
  end
end
