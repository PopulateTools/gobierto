# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoInvestments
    module Projects
      class ProjectsIndexTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_investments_projects_path
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def unauthorized_regular_admin
          @unauthorized_regular_admin ||= gobierto_admin_admins(:steve)
        end

        def authorized_regular_admin
          @authorized_regular_admin ||= gobierto_admin_admins(:tony)
        end

        def site
          @site ||= sites(:madrid)
        end

        def projects
          @projects ||= site.projects
        end

        def test_regular_admin_permissions_not_authorized
          with(site: site, admin: unauthorized_regular_admin) do
            visit @path
            assert has_content?("You are not authorized to perform this action")
            assert_equal admin_root_path, current_path
          end
        end

        def test_regular_admin_permissions_authorized
          with(site: site, admin: authorized_regular_admin) do
            visit @path
            assert has_no_content?("You are not authorized to perform this action")
            assert_equal @path, current_path
          end
        end

        def test_projects_index
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "table tbody" do
                assert has_selector?("tr", count: projects.size)

                projects.each do |project|
                  assert has_selector?("tr#project-item-#{ project.id }")

                  within "tr#project-item-#{ project.id }" do
                    assert has_link?(project.title)
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
