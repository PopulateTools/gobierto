# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  class DeleteScopeTest < ActionDispatch::IntegrationTest
    
    def setup
      super
      @path = admin_scopes_path
      site.processes.where(scope: scope).update_all(scope_id: nil)
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def site
      @site ||= sites(:madrid)
    end

    def scope
      @scope ||= gobierto_common_scopes(:old_town)
    end

    def scope_with_items
      @scope_with_items ||= gobierto_common_scopes(:center)
    end

    def test_delete_scope
      with_signed_in_admin(admin) do
        with_current_site(site) do
          visit @path

          within "#scope-item-#{scope.id}" do
            find("a[data-method='delete']").click
          end

          assert has_message?('Scope was successfully destroyed.')

          refute site.scopes.exists?(id: scope.id)
        end
      end
    end

    def test_delete_scope_with_items
      with_signed_in_admin(admin) do
        with_current_site(site) do
          visit @path

          within "#scope-item-#{scope_with_items.id}" do
            find("a[data-method='delete']").click
          end

          assert has_message?("You can't delete a scope while it has associated elements.")

          assert site.scopes.exists?(id: scope_with_items.id)
        end
      end
    end

  end
end
