# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCms
    class CreateSectionTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_cms_sections_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_create_section_errors
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link "New"
              click_button "Create"

              assert has_alert?("Title can't be blank")
            end
          end
        end
      end

      def test_create_section
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link "New"

              fill_in "section_title_translations_en", with: "My section"
              fill_in "section_slug", with: "my-section"

              click_link "ES"
              fill_in "section_title_translations_es", with: "Mi sección"

              click_button "Create"

              assert has_message?("Section created successfully")

              assert has_selector?("h1", text: "My section")
            end
          end
        end
      end
    end
  end
end
