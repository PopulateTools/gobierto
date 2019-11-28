# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoData
    module Datasets
      class DatasetsIndexTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_data_datasets_path
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

        def datasets
          @datasets ||= site.datasets
        end

        def test_regular_admin_permissions_not_authorized
          with(site: site, admin: unauthorized_regular_admin) do
            visit @path
            assert has_content?("You are not authorized to perform this action")
            assert_equal edit_admin_admin_settings_path, current_path
          end
        end

        def test_regular_admin_permissions_authorized
          with(site: site, admin: authorized_regular_admin) do
            visit @path
            assert has_no_content?("You are not authorized to perform this action")
            assert_equal @path, current_path
          end
        end

        def test_datasets_index
          with(site: site, admin: admin) do
            visit @path

            within "table tbody" do
              assert has_selector?("tr", count: datasets.size)

              datasets.each do |dataset|
                assert has_selector?("tr#dataset-item-#{ dataset.id }")

                within "tr#dataset-item-#{ dataset.id }" do
                  assert has_link?(dataset.name)
                end
              end
            end
          end
        end
      end
    end
  end
end
