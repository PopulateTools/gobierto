require 'test_helper'

module GobiertoAdmin
  module GobiertoCommon
    class UpdateCollectionTest < ActionDispatch::IntegrationTest
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

      def participation_issue
        @participation_issue ||= gobierto_participation_issues(:culture)
      end

      def test_update_issue
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link 'News'
              click_link 'Configuration'

              within 'form.edit_collection' do
                fill_in 'collection_title_translations_en', with: 'News updated'
                fill_in 'collection_slug', with: 'news-updated'

                click_button 'Update'
              end

              assert has_message?('Collection was successfully updated.')
            end
          end
        end
      end
    end
  end
end
