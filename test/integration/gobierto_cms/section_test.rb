# frozen_string_literal: true

require "test_helper"

module GobiertoCms
  class SectionTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def section
      @section ||= gobierto_cms_sections(:participation)
    end

    def pages_in_section
      @pages_in_section ||= [ gobierto_cms_pages(:about_participation), gobierto_cms_pages(:how_to_participate) ]
    end

    def test_visit_section
      with_current_site(site) do
        visit gobierto_cms_section_path(section.slug)

        pages_in_section.each do |page|
          assert has_link?(page.title)
        end
      end
    end
  end
end
