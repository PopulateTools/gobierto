# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoData
    module Datasets
      class UpdateDatasetTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = edit_admin_data_dataset_path(dataset)
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

        def dataset
          @dataset ||= gobierto_data_datasets(:users_dataset)
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

        def test_update_dataset
          with(site: site, admin: admin, js: true) do
            visit @path

            fill_in "dataset_name_translations_en", with: "Vocabulary updated"
            switch_locale "ES"
            fill_in "dataset_name_translations_es", with: "Vocabulario actualizado"
            select "terms", from: "dataset_table_name"
            fill_in "dataset_slug", with: "vocabularies-updated-slug"

            click_button "Update"

            assert has_message?("Dataset updated correctly.")
            assert has_field? "dataset_name_translations_en", with: "Vocabulary updated"
            switch_locale "ES"
            assert has_field?("dataset_name_translations_es", with: "Vocabulario actualizado")
            assert has_field?("dataset_slug", with: "vocabularies-updated-slug")
            assert has_select?("Table name", selected: "terms")
          end

          activity = Activity.last
          assert_equal dataset, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_data.dataset.dataset_updated", activity.action
        end

        def test_update_dataset_error
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                fill_in "dataset_name_translations_en", with: ""
                switch_locale "ES"
                fill_in "dataset_name_translations_es", with: ""

                click_button "Update"

                assert has_alert?("can't be blank")
              end
            end
          end
        end

        def test_update_custom_field_updates_dataset
          with(site: site, admin: admin) do
            visit @path

            assert_changes "dataset.reload.updated_at" do
              select "Economy", from: "dataset_custom_records_category_value"
              click_button "Update"
              assert has_message?("Dataset updated correctly.")
              assert has_select?("Category", selected: "Economy")
            end
          end
        end
      end
    end
  end
end
