# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  module GobiertoAdmin
    module Vocabulary
      class UpdateVocabularyTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_common_vocabularies_path
        end

        def vocabulary
          @vocabulary ||= gobierto_common_vocabularies(:animals)
        end

        def admin
          @admin ||= gobierto_admin_admins(:tony)
        end

        def unauthorized_admin
          @unauthorized_admin ||= gobierto_admin_admins(:steve)
        end

        def site
          @site ||= sites(:madrid)
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

        def test_update_vocabulary
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                find(:xpath, %Q{//a[@href="#{edit_admin_common_vocabulary_path(vocabulary)}"]}).click

                within "form.edit_vocabulary" do
                  fill_in "vocabulary_name_translations_en", with: "Animals updated"
                  fill_in "vocabulary_slug", with: "animals-updated"

                  click_button "Update"
                end

                assert has_message?("Vocabulary updated successfully.")

                find(:xpath, %Q{//a[@href="#{edit_admin_common_vocabulary_path(vocabulary)}"]}).click

                assert has_field? "vocabulary_name_translations_en", with: "Animals updated"
                assert has_field? "vocabulary_slug", with: "animals-updated"
              end
            end
          end
        end
      end
    end
  end
end
