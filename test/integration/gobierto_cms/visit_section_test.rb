# frozen_string_literal: true

require "test_helper"

module GobiertoCms
  class VisitSectionTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_cms_section_path(section.slug)
    end

    def site
      @site ||= sites(:madrid)
    end

    def section
      @section ||= gobierto_cms_sections(:participation)
    end

    def section_pages
      @section_pages ||= [gobierto_cms_pages(:about_participation)]
    end

    def section_page
      section_pages.first
    end

    def test_visit_section
      with_current_site(site) do
        visit @path

        assert has_content?(section.title)

        section_pages.each do |page|
          assert has_link?(page.title)
        end

        click_link section_page.title

        assert has_content?(section_page.title)
        assert has_content?(section.title)
      end
    end
  end
end
