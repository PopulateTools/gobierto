# frozen_string_literal: true

require "test_helper"

module GobiertoCms
  class VisitPagesCollectionTest < ActionDispatch::IntegrationTest

    def madrid
      @madrid ||= sites(:madrid)
    end

    def santander
      @santander ||= sites(:santander)
    end

    def santander_cms_collection
      @santander_cms_collection ||= gobierto_common_collections(:santander_cms_pages)
    end

    def participation_collection
      @participation_collection ||= gobierto_common_collections(:participation_pages)
    end

    def participation_collection_pages
      @participation_collection_pages ||= madrid.pages.where(id: participation_collection.pages_in_collection).active
    end

    def participation_collection_page
      participation_collection_pages.first
    end

    def test_visit_collection
      collection_public_pages = [
        gobierto_cms_pages(:cms_section_l0_p0_page),
        gobierto_cms_pages(:cms_section_l0_p1_page)
      ]

      collection_hidden_pages = [
        gobierto_cms_pages(:cms_section_l0_p2d_page),
        gobierto_cms_pages(:cms_section_l0_p3a_page)
      ]

      with_current_site(santander) do
        visit gobierto_cms_pages_path(santander_cms_collection.slug)

        assert has_content?(santander_cms_collection.title)

        collection_public_pages.each do |page|
          assert has_link?(page.title)
        end

        collection_hidden_pages.each do |page|
          refute has_link?(page.title)
        end

        collection_page = collection_public_pages.first

        click_link collection_page.title

        assert has_content?(collection_page.title)
      end
    end

    def test_visit_participation_collection
      with_current_site(madrid) do
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
