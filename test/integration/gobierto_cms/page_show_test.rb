# frozen_string_literal: true

require "test_helper"

module GobiertoCms
  class PageShowTest < ActionDispatch::IntegrationTest
    def page_path
      @page_path ||= gobierto_cms_section_path(
        id: cms_page.slug,
        slug_section: section.slug
      )
    end

    def site
      @site ||= sites(:madrid)
    end

    def section
      @section ||= gobierto_cms_sections(:participation)
    end

    def cms_page
      @cms_page ||= gobierto_cms_pages(:about_participation)
    end

    def test_pages_show
      with_javascript do
        with_current_site(site) do
          visit page_path

          within ".global_breadcrumb" do
            assert has_link? section.title
          end

          within ".breadcrumb" do
            assert has_link? section.title
          end

          within ".side_navigation" do
            assert has_link? cms_page.title
          end

          within "article" do
            assert has_selector?("h1", text: cms_page.title)
            assert has_content?(cms_page.body)
          end
        end
      end
    end
  end
end
