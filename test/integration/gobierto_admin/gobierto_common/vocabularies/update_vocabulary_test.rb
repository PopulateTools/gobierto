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
          @admin ||= gobierto_admin_admins(:nick)
        end

        def site
          @site ||= sites(:madrid)
        end

        def test_update_vocabulary
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                click_link vocabulary.name

                within "form.edit_vocabulary" do
                  fill_in "vocabulary_name_translations_en", with: "Animals updated"
                  fill_in "vocabulary_slug", with: "animals-updated"

                  click_button "Update"
                end

                assert has_message?("Vocabulary updated successfully.")

                click_link vocabulary.name

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
