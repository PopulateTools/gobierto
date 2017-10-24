# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  class CreateScopeTest < ActionDispatch::IntegrationTest

    def setup
      super
      @path = admin_scopes_path
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_create_scope_errors
      with_javascript do
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            click_link 'New'
            click_button 'Create'

            assert has_alert? "Name can't be blank"
          end
        end
      end
    end

    def test_create_scope
      with_javascript do
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            click_link 'New'

            fill_in 'scope_name_translations_en', with: 'New scope name'
            fill_in 'scope_description_translations_en', with: 'New scope description'

            click_link 'ES'

            fill_in 'scope_name_translations_es', with: 'Nombre del nuevo ámbito'
            fill_in 'scope_description_translations_es', with: 'Descripción del nuevo ámbito'

            click_button 'Create'

            assert has_message?('Scope was successfully created')

            assert has_content?('New scope name')

            # assert scope was created

            scope = site.scopes.last

            assert_equal 'New scope name', scope.name
            assert_equal 'New scope description', scope.description

            assert_equal 'Nombre del nuevo ámbito', scope.name_es
            assert_equal 'Descripción del nuevo ámbito', scope.description_es

            # assert create activity was generated

            activity = Activity.last

            assert_equal scope, activity.subject
            assert_equal admin, activity.author
            assert_equal site.id, activity.site_id
            assert_equal 'scopes.scope_created', activity.action
          end
        end
      end
    end
  end
end
