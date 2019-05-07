# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/previewable_item_test_module"

module GobiertoAdmin
  module GobiertoParticipation
    class ProcessPagesTest < ActionDispatch::IntegrationTest

      include ::GobiertoAdmin::PreviewableItemTestModule

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

      def process_news_index
        @process_news_index ||= gobierto_common_collections(:gender_violence_process_news)
      end

      def cms_page
        @cms_page ||= gobierto_cms_pages(:notice_1)
      end
      alias news cms_page

      def preview_test_conf
        {
          item_admin_path: edit_admin_cms_page_path(news, collection_id: process_news_index.id),
          item_public_url: news.to_url
        }
      end

      def chosen_publication_date
        Time.zone.parse("2017-01-01 23:59")
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

              # find("#page_body_translations_en", visible: false).set("The content of the page")
              page.execute_script('document.getElementById("page_body_translations_en").innerText = "The content of the page"')
  
              fill_in "page_published_on", with: chosen_publication_date

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
              fill_in "page_published_on", with: chosen_publication_date

              click_button "Update"

              assert has_message?("Page updated successfully")

              assert has_selector?("h1", text: process.title)
              assert_equal chosen_publication_date.to_s, air_datepicker_field_value(:page_published_on)

              within ".tabs" do
                click_link "News"
              end

              assert has_content?("My page updated")
              assert has_no_content?(cms_page.title)
            end
          end
        end
      end

      def test_preview_news_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit admin_participation_process_pages_path(process)

            assert preview_link_excludes_token?
            click_preview_link

            assert has_content? "News for #{process.title}"

            process.draft!

            visit admin_participation_process_pages_path(process)

            assert preview_link_includes_token?
            click_preview_link

            assert has_content? "News for #{process.title}"
          end
        end
      end

    end
  end
end
