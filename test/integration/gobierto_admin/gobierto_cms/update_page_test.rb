# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  module GobiertoCms
    class UpdatePageTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_cms_pages_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def cms_page
        @cms_page ||= gobierto_cms_pages(:consultation_faq)
      end

      def test_update_page
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link 'Consultation page FAQ'

              fill_in 'page_title_translations_en', with: 'Consultation page FAQ updated'
              fill_in 'page_slug_translations_en', with: 'consultation-faq-updated'

              click_button 'Update'

              assert has_message?('Page updated successfully')
              assert has_selector?('h1', text: 'Consultation page FAQ updated')
              assert has_field?('page_slug_translations_en', with: 'consultation-faq-updated')
              assert_equal('faq-consultas', find('#page_slug_translations_es', visible: false).value)

              assert_equal(
                '<div>This is the body of the page</div>',
                find('#page_body_translations_en', visible: false).value
              )

              activity = Activity.last
              assert_equal cms_page, activity.subject
              assert_equal admin, activity.author
              assert_equal site.id, activity.site_id
              assert_equal 'gobierto_cms.page_updated', activity.action

              click_link 'View the page'

              assert has_content?('Consultation page FAQ updated')
              assert has_content?('This is the body of the page')

              visit @path
            end
          end
        end
      end
    end
  end
end
