# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Services
      class ServicesIndexTest < ActionDispatch::IntegrationTest
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

        def services
          @services ||= site.services
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

        def test_services_index
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "table tbody" do
                assert has_selector?("tr", count: services.size)

                services.each do |service|
                  assert has_selector?("tr#service-item-#{service.id}")

                  within "tr#service-item-#{service.id}" do
                    assert has_link?(service.title)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
