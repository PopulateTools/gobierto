# frozen_string_literal: true

require "test_helper"

module GobiertoCms
  class VisitPageTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_cms_page_path(cms_page.slug)
    end

    def site
      @site ||= sites(:madrid)
    end

    def cms_page
      @cms_page ||= gobierto_cms_pages(:about_site)
    end

    def attachments
      @attachments ||= cms_page.attachments
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit @path

        within ".global_breadcrumb" do
          assert has_link? cms_page.collection.title
        end
      end
    end

    def test_breadcrumb_page
      with_current_site(site) do
        visit @path

        within ".breadcrumb" do
          assert has_content? cms_page.collection.title
          assert has_content? cms_page.title
        end
      end
    end

    def test_visit_page
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: cms_page.title)
        assert has_content?(cms_page.body)

        within ".page_attachments" do
          attachments.each do |attachment|
            assert has_link? attachment.name
          end
        end
      end
    end
  end
end
