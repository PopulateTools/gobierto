# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessPagesIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def process_pages_path
      @process_pages_path ||= gobierto_participation_process_pages_path(
        process_id: process.slug
      )
    end

    def process_pages
      @process_pages ||= process.news
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit process_pages_path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
          assert has_link? "Processes"
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit process_pages_path

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
        visit process_pages_path

        within "menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Diary"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit process_pages_path

        within ".site_header" do
          assert has_content? "Follow this process"
        end
      end
    end

    def test_process_pages_index
      with_current_site(site) do
        visit process_pages_path

        assert_equal process_pages.size, all(".news_teaser").size
        assert has_content? "Notice 1 body"
        assert has_link? "Notice 1 title"
        assert has_content? "Notice 2 body"
        assert has_link? "Notice 2 title"
      end
    end
  end
end
