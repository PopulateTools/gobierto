# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module Vocabularies
      class CreateVocabularyTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_common_vocabularies_path
        end

        def site
          @site ||= sites(:madrid)
        end

        def admin
          @admin ||= gobierto_admin_admins(:tony)
        end

        def unauthorized_admin
          @unauthorized_admin ||= gobierto_admin_admins(:steve)
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

        def test_create_vocabulary_errors
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                click_link "New"
                click_button "Create"

                assert has_alert?("Name can't be blank")
              end
            end
          end
        end

        def test_create_vocabulary
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                click_link "New"

                fill_in "vocabulary_name_translations_en", with: "Monetary Systems"
                fill_in "vocabulary_slug", with: "monetary-systems-new"

                click_link "ES"
                fill_in "vocabulary_name_translations_es", with: "Sistemas Monetarios"

                click_button "Create"

                assert has_message?("Vocabulary created successfully.")

                vocabulary = site.vocabularies.last
                find(:xpath, %Q{//a[@href="#{edit_admin_common_vocabulary_path(vocabulary)}"]}).click

                assert has_field?("vocabulary_name_translations_en", with: "Monetary Systems")
                assert has_field?("vocabulary_slug", with: "monetary-systems-new")

                click_link "ES"

                assert has_field?("vocabulary_name_translations_es", with: "Sistemas Monetarios")
              end
            end
          end
        end
      end
    end
  end
end
