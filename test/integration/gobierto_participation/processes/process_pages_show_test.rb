# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessPagesShowTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def process_page
      @process_page ||= gobierto_cms_pages(:notice_1)
    end

    def process_page_path
      @process_page_path ||= gobierto_participation_process_page_path(
        process_page.slug,
        process_id: process.slug
      )
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit process_page_path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
          assert has_link? "Processes"
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit process_page_path

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
        visit process_page_path

        within "menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Participation Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end

        # TODO: check that these links redirect to their corresponding pages
        # applying the right scope (single process/group scope)
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit process_page_path

        within ".site_header" do
          assert has_content? "Follow this process"
        end
      end
    end

    def test_process_page_show
      with_current_site(site) do
        visit process_page_path

        within ".news_article" do
          assert has_content? "Notice 1 title"
          assert has_content? "Notice 1 body"
        end
      end
    end
  end
end
