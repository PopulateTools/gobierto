# frozen_string_literal: true

require "test_helper"

module GobiertoCms
  class NewsCollectionTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def collection
      @collection ||= gobierto_common_collections(:site_news)
    end

    def pages_in_collection
      @pages_in_section ||= [ gobierto_cms_pages(:site_news_1), gobierto_cms_pages(:site_news_2) ]
    end

    def test_visit_collection
      with_current_site(site) do
        visit gobierto_cms_pages_path(collection.slug)

        pages_in_collection.each do |page|
          assert has_link?(page.title)
        end
      end
    end
  end
end
