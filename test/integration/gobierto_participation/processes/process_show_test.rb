# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_participation_process_path(gender_violence_process.slug)
    end

    def site
      @site ||= sites(:madrid)
    end

    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def process_information_path
      @process_information_path ||= edit_admin_participation_process_process_information_path(
        id: process,
        process_id: process
      )
    end

    def gender_violence_process
      @gender_violence_process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def green_city_group
      @green_city_group ||= gobierto_participation_processes(:green_city_group)
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit @path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
          assert has_link? "Processes"
          assert has_link? gender_violence_process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit @path

        within "menu.sub_sections" do
          assert has_link? "Information"
          assert has_link? "Meetings"
          assert has_link? "Polls"
          assert has_link? "Contributions"
          assert has_link? "Results"
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

        # TODO: check that these links redirect to their corresponding pages
        # applying the right scope (single process/group scope)
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit @path

        within ".site_header" do
          assert has_content? "Follow this process"
        end
      end
    end

    def test_process
      with_current_site(site) do
        visit @path

        within ".container" do
          assert has_content? gender_violence_process.title
          assert has_content? gender_violence_process.body

          assert has_content? "Interesting information"

          process_duration_text = "#{gender_violence_process.starts.strftime("%e/%m/%y")} to #{gender_violence_process.ends.strftime("%e/%m/%y")}"

          assert has_content? process_duration_text
          assert has_content? "Women"
          # TODO: assert has_content? 'Strategic' (~Ámbito)
        end
      end
    end

    def test_process_news
      with_current_site(site) do
        visit @path

        assert_equal gender_violence_process.news_in_collections.size, all(".place_news-item").size

        news_titles = gender_violence_process.news_in_collections.map(&:title)

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
        visit @path

        assert_equal gender_violence_process.events_in_collections.size, all(".place_event-item").size

        events_titles = gender_violence_process.events_in_collections.map(&:title)

        assert array_match ["Intensive reading club in english", "Swimming lessons for elders"], events_titles
      end
    end

    def test_process_information
      with_current_site(site) do
        visit @path

        click_on "Information"

        assert has_content? process.information_text
      end
    end

    def test_process_without_events
      with_current_site(site) do
        visit gobierto_participation_process_path(green_city_group.slug)

        assert has_content? "There are no related events"
      end
    end

    def test_process_activities
      with_current_site(site) do
        visit @path

        skip "Not yet defined"
      end
    end

    def test_process_stages
      with_current_site(site) do
        visit @path

        within ".timeline" do
          assert_equal gender_violence_process.stages.size, all(".timeline_row").size
        end
      end
    end

    def test_process_without_stages
      with_current_site(site) do
        visit gobierto_participation_process_path(green_city_group.slug)

        refute has_content? "Process stages"
      end
    end
  end
end
