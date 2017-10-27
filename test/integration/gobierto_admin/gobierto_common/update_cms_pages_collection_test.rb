# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    class UpdateCmsPagesCollectionTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_participation_process_pages_path(process.id)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @sport_city_process ||= gobierto_participation_processes(:sport_city_process)
      end

      def test_update_pages_collection
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_on "Configuration"

              within "form.edit_collection" do
                fill_in "collection_title_translations_en", with: "News updated"
                fill_in "collection_slug", with: "news-updated"

                click_button "Update"
              end

              assert has_message?("Collection was successfully updated.")
            end
          end
        end
      end
    end
  end
end
