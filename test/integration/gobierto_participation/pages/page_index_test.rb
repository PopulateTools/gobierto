# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class PageIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_participation_process_path(gender_violence_process.slug)
    end

    def site
      @site ||= sites(:madrid)
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
          assert has_content? "Information"
          assert has_content? "Meetings"
          assert has_content? "Polls"
          assert has_content? "Contributions"
          assert has_content? "Results"
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

    def test_process_news
      with_current_site(site) do
        visit @path

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

    def test_menu_news
      with_current_site(site) do
        visit @path

        click_link "News"

        assert has_selector?("h2", text: "News")

        green_city_group.news.each do |page|
          assert has_selector?("news_teaser")

          within "news_teaser" do
            assert has_link?(page.title)
          end
        end
      end
    end
  end
end
