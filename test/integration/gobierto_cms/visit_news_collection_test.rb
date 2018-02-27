# frozen_string_literal: true

require "test_helper"

module GobiertoCms
  class VisitPagesCollectionTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def site_collection
      @site_collection ||= gobierto_common_collections(:site_news)
    end

    def site_collection_pages
      @site_collection_pages ||= site.pages.where(id: site_collection.pages_in_collection).active
    end

    def site_collection_page
      site_collection_pages.first
    end

    def participation_process_collection
      @participation_process_collection ||= gobierto_common_collections(:news)
    end

    def participation_process_collection_pages
      @participation_process_collection_pages ||= site.pages.where(id: participation_process_collection.pages_in_collection).active
    end

    def participation_process_collection_page
      participation_process_collection_pages.first
    end

    def test_visit_site_collection
      with_current_site(site) do
        visit gobierto_cms_news_index_path(site_collection.slug)

        assert has_content?(site_collection.title)

        site_collection_pages.each do |page|
          assert has_link?(page.title)
        end

        click_link site_collection_page.title

        assert has_content?(site_collection_page.title)
        assert has_content?(site_collection.title)
      end
    end

    def test_visit_participation_process_collection
      with_current_site(site) do
        visit gobierto_cms_news_index_path(participation_process_collection.slug)

        assert has_content?(participation_process_collection.title)

        participation_process_collection_pages.each do |page|
          assert has_link?(page.title)
        end

        click_link participation_process_collection_page.title

        assert has_content?(participation_process_collection_page.title)
        assert has_content?(participation_process_collection.title)

        within "nav.main-nav" do
          within ".main-nav-item.active" do
            assert has_content?(participation_process_collection.container.title)
          end
        end
      end
    end
  end
end
