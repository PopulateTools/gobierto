# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoData
    module Datasets
      class CreateDatasetTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = new_admin_data_dataset_path
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

        def test_create_dataset_errors
          with(site: site, admin: admin, js: true) do
            visit @path

            click_button "Create"

            assert has_alert?("Name can't be blank")
          end
        end

        def test_create_dataset
          with(site: site, admin: admin, js: true) do
            visit @path

            fill_in "dataset_name_translations_en", with: "Vocabularies"
            switch_locale "ES"
            fill_in "dataset_name_translations_es", with: "Vocabularios"
            select "vocabularies", from: "dataset_table_name"
            fill_in "dataset_slug", with: "vocabularies-slug"

            click_button "Create"

            assert has_message?("Dataset created correctly.")
            assert has_field?("dataset_name_translations_en", with: "Vocabularies")
            switch_locale "ES"
            assert has_field?("dataset_name_translations_es", with: "Vocabularios")
            assert has_field?("dataset_slug", with: "vocabularies-slug")
            assert has_select?("Table name", selected: "vocabularies")
          end

          activity = Activity.last
          new_dataset = ::GobiertoData::Dataset.last
          assert_equal new_dataset, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_data.dataset.dataset_created", activity.action
        end
      end
    end
  end
end
