# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  class ScopesIndexTest < ActionDispatch::IntegrationTest

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

    def scopes
      @scopes ||= site.scopes
    end

    def test_scopes_index
      with_signed_in_admin(admin) do
        with_current_site(site) do
          visit @path

          within 'table tbody' do
            assert has_selector?('tr', count: scopes.size)

            scopes.each do |scope|
              within "#scope-item-#{scope.id}" do
                assert has_link?(scope.name.to_s)
              end
            end
          end
        end
      end
    end
    
  end
end
