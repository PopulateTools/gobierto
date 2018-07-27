# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class DeleteScopeTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = admin_common_vocabulary_terms_path(scopes_vocabulary)
      site.processes.where(scope: scope).update_all(scope_id: nil)
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

    def scope_with_items
      @scope_with_items ||= gobierto_common_terms(:center_term)
    end

    def test_delete_scope
      with_signed_in_admin(admin) do
        with_current_site(site) do
          visit @path

          within "#term-item-#{scope.id}" do
            find("a[data-method='delete']").click
          end

          assert has_message?("Term deleted successfully.")

          refute site.scopes.exists?(id: scope.id)
        end
      end
    end

    def test_delete_scope_with_items
      with_signed_in_admin(admin) do
        with_current_site(site) do
          visit @path

          within "#term-item-#{scope_with_items.id}" do
            find("a[data-method='delete']").click
          end

          assert has_message?("You can't delete a term while it has associated elements.")

          assert site.scopes.exists?(id: scope_with_items.id)
        end
      end
    end
  end
end
