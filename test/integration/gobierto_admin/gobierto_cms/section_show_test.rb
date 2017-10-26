# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCms
    class SectionShowTest < ActionDispatch::IntegrationTest
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

      def sections
        @sections ||= site.sections
      end

      def participation_section
        @participation_section ||= gobierto_cms_section_items(:participation_items)
      end

      def test_sections_show
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "table tbody" do
              click_link participation_section.section.title
            end

            assert has_selector?("h1", text: participation_section.section.title)
            assert has_content? "Last edited pages"
          end
        end
      end
    end
  end
end
