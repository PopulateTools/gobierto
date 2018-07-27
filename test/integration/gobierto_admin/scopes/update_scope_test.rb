# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  class UpdateScopeTest < ActionDispatch::IntegrationTest
    
    def setup
      super
      @path = admin_common_vocabulary_terms_path(scopes_vocabulary)
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def site
      @site ||= sites(:madrid)
    end

    def scopes_vocabulary
      gobierto_common_vocabularies(:scopes_vocabulary)
    end

    def scope
      @scope ||= gobierto_common_terms(:old_town_term)
    end

    def test_update_scope
      with_javascript do
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            click_link scope.name

            fill_in 'term_name_translations_en', with: 'Updated scope name'
            fill_in 'term_description_translations_en', with: 'Updated scope description'

            click_button 'Update'

            assert has_message?('Term updated successfully.')

            # assert scope was updated

            scope.reload

            assert_equal 'Updated scope name', scope.name
            assert_equal 'Updated scope description', scope.description

            # assert update activity was generated

            activity = Activity.last
            
            assert_equal scope, activity.subject
            assert_equal admin, activity.author
            assert_equal site.id, activity.site_id
            assert_equal 'gobierto_common.term_updated', activity.action
          end
        end
      end
    end

  end
end
