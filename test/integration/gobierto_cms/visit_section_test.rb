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
      @section_pages ||= [gobierto_cms_pages(:about_participation), gobierto_cms_pages(:about_participation_details)]
    end

    def section_page
      section_pages.first
    end

    def section_page_child
      section_pages.last
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

    def test_list_children_pages
      with_current_site(site) do
        section_child = GobiertoCms::SectionItem.find_by_item_id(section_page_child.id)
        section_parent = GobiertoCms::SectionItem.find_by_item_id(section_page.id)
        section_child.parent_id = section_parent.id
        section_child.level += 1
        section_child.save

        visit @path

        within "article" do
          within "div.page_children" do
            within "div.page_child" do
              assert has_link?(section_page_child.title)
            end
          end
        end
      end
    end
  end
end
