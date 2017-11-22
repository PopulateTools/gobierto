# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class ProcessPagesTest < ActionDispatch::IntegrationTest
      def setup
        super
        collection.append(cms_page)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:gender_violence_process)
      end

      def collection
        @collection ||= gobierto_common_collections(:gender_violence_process_calendar)
      end

      def cms_page
        @cms_page ||= gobierto_cms_pages(:notice_1)
      end

      def test_create_page
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit edit_admin_participation_process_path(process)

              within ".tabs" do
                click_link "News"
              end

              within ".admin_tools" do
                click_link "New"
              end

              assert has_selector?("h1", text: process.title)

              fill_in "page_title_translations_en", with: "News Title"
              find("#body_translations_en", visible: false).set("The content of the page")

              click_button "Create"

              assert has_message?("Page created successfully")

              assert has_selector?("h1", text: process.title)

              within ".tabs" do
                click_link "News"
              end

              assert has_content?("News Title")
            end
          end
        end
      end

      def test_edit_page
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit edit_admin_cms_page_path(cms_page, collection_id: process.news_collection)

              assert has_selector?("h1", text: process.title)

              fill_in "page_title_translations_en", with: "My page updated"
              click_button "Update"

              assert has_message?("Page updated successfully")

              assert has_selector?("h1", text: process.title)

              within ".tabs" do
                click_link "News"
              end

              assert has_content?("My page updated")
              refute has_content?(cms_page.title)
            end
          end
        end
      end
    end
  end
end
