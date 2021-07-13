# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoData
    module Datasets
      class DeleteDatasetTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_data_datasets_path
        end

        def authorized_regular_admin
          @authorized_regular_admin ||= gobierto_admin_admins(:tony)
        end

        def site
          @site ||= sites(:madrid)
        end

        def dataset
          @dataset ||= gobierto_data_datasets(:users_dataset)
        end

        def test_delete_dataset
          with(site: site, admin: authorized_regular_admin) do

            assert_difference "site.activities.where(action: \"gobierto_data.dataset_dataset_deleted\").count", 1 do
              visit @path

              within "#dataset-item-#{dataset.id}" do
                find("a[data-method='delete']").click
              end

              assert has_message?("Dataset deleted correctly.")

              refute site.datasets.exists?(id: dataset.id)
            end
          end
        end
      end
    end
  end
end
