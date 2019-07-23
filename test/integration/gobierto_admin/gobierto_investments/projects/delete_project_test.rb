# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoInvestments
    module Projects
      class DeleteProjectTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_investments_projects_path
        end

        def authorized_regular_admin
          @authorized_regular_admin ||= gobierto_admin_admins(:tony)
        end

        def site
          @site ||= sites(:madrid)
        end

        def project
          @project ||= gobierto_investments_projects(:public_pool_project)
        end

        def test_delete_project
          with(site: site, admin: authorized_regular_admin) do
            visit @path

            within "#project-item-#{project.id}" do
              find("a[data-method='delete']").click
            end

            assert has_message?("Project deleted correctly.")

            refute site.projects.exists?(id: project.id)
          end
        end
      end
    end
  end
end
