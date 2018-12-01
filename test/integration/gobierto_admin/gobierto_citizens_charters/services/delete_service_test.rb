# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Services
      class DeleteServiceTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_citizens_charters_services_path
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def unauthorized_admin
          @unauthorized_admin ||= gobierto_admin_admins(:steve)
        end

        def site
          @site ||= sites(:madrid)
        end

        def service
          @service ||= gobierto_citizens_charters_services(:teleassistance)
        end

        def test_permissions
          with_signed_in_admin(unauthorized_admin) do
            with_current_site(site) do
              visit @path
              assert has_content?("You are not authorized to perform this action")
              assert_equal admin_root_path, current_path
            end
          end
        end

        def test_delete_service
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#service-item-#{service.id}" do
                find("a[data-method='delete']").click
              end

              assert has_message?("The service has been correctly archived")

              refute site.services.exists?(id: service.id)
            end
          end
        end
      end
    end
  end
end
