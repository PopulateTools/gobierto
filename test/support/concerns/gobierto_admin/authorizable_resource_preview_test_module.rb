# frozen_string_literal: true

module GobiertoAdmin
  module AuthorizableResourcePreviewTestModule
    include PermissionHelpers

    def setup_authorizable_resource_preview_test(admin, authorized_resource_path, unauthorized_resource_path, resource_person = nil)
      @authorizable_admin = admin
      @authorized_resource_path = authorized_resource_path
      @unauthorized_resource_path = unauthorized_resource_path
      @resource_person = resource_person
      # Most tests use 'Steve'. Grant module permissions to make
      # sure action is rejected because resource permissions don't
      # exist, not because of module ones.
      setup_specific_permissions(@authorizable_admin, module: "gobierto_people", site: site)
    end

    def test_preview_resource
      with_current_site(site) do
        visit "#{@authorized_resource_path}?preview_token=#{@authorizable_admin.preview_token}"
        assert has_no_content?("You do not have enough permissions to perform this action")
      end
    end

    def test_preview_resource_without_permissions
      @resource_person&.draft!

      with_current_site(site) do
        visit "#{@unauthorized_resource_path}?preview_token=#{@authorizable_admin.preview_token}"
        assert has_content?("You do not have enough permissions to perform this action")
      end
    end

  end
end
