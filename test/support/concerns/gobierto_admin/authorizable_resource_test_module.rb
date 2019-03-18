# frozen_string_literal: true

module GobiertoAdmin
  module AuthorizableResourceTestModule
    include PermissionHelpers

    def setup_authorizable_resource_test(admin, resource_path)
      @unauthorized_admin = admin
      @unauthorized_resource_path = resource_path
      # Most tests use 'Steve'. Grant module permissions to make
      # sure action is rejected because resource permissions don't
      # exist, not because of module ones.

      setup_specific_permissions(@unauthorized_admin, module: "gobierto_people", site: site)
    end

    def test_access_resource_without_permissions
      with_signed_in_admin(@unauthorized_admin) do
        with_current_site(site) do
          visit @unauthorized_resource_path
          assert has_message?("You do not have enough permissions to perform this action")
        end
      end
    end

  end
end