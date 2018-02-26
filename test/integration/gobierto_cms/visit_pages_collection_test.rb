# frozen_string_literal: true

require "test_helper"

module GobiertoCms
  class VisitPagesCollectionTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def site_collection
      @site_collection ||= gobierto_common_collections(:site_pages)
    end

    def site_collection_pages
      @site_collection_pages ||= site.pages.where(id: site_collection.pages_in_collection).active
    end

    def site_collection_page
      site_collection_pages.first
    end

    def participation_collection
      @participation_collection ||= gobierto_common_collections(:participation_pages)
    end

    def participation_collection_pages
      @participation_collection_pages ||= site.pages.where(id: participation_collection.pages_in_collection).active
    end

    def participation_collection_page
      participation_collection_pages.first
    end

    def test_visit_site_collection
      with_current_site(site) do
        visit gobierto_cms_pages_path(site_collection.slug)

        assert has_content?(site_collection.title)

        site_collection_pages.each do |page|
          assert has_link?(page.title)
        end

        click_link site_collection_page.title

        assert has_content?(site_collection_page.title)
        assert has_content?(site_collection.title)

        assert has_content?("#{site_collection.title} / #{site_collection_page.title}")
      end
    end

    def test_visit_participation_collection
      with_current_site(site) do
        visit gobierto_cms_pages_path(participation_collection.slug)

        assert has_content?(participation_collection.title)

        participation_collection_pages.each do |page|
          assert has_link?(page.title)
        end

        click_link participation_collection_page.title

        assert has_content?(participation_collection_page.title)
        assert has_content?(participation_collection.title)

        assert has_content?("#{participation_collection.title} / #{participation_collection_page.title}")

        within "nav.main-nav" do
          within ".main-nav-item.active" do
            assert has_content?("Participation")
          end
        end
      end
    end
  end
end
