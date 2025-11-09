# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module Terms
      class CreateTermTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_common_vocabulary_terms_path(vocabulary)
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

              assert has_no_link? "New"
            end
          end
        end

        def test_create_term_errors
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                click_link "New"
                click_button "Create"

                assert has_alert?("Name translations can't be blank")
              end
            end
          end
        end

        def test_create_term
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                click_link "New"

                fill_in "term_name_translations_en", with: "Goat"
                fill_in "term_description_translations_en", with: "The goat is an animal"
                fill_in "term_slug", with: "new-goat"
                fill_in "term_external_id", with: "animal_1"

                switch_locale "ES"
                fill_in "term_name_translations_es", with: "Cabra"
                fill_in "term_description_translations_es", with: "La cabra es un animal"

                click_button "Create"

                assert has_message?("Term created successfully.")

                new_term = vocabulary.terms.last
                within("#v_el_actions_#{new_term.id}", visible: false) do
                  click_link "Edit", visible: false
                end

                assert has_field?("term_name_translations_en", with: "Goat")
                assert has_field?("term_description_translations_en", with: "The goat is an animal")
                assert has_field?("term_slug", with: "new-goat")
                assert has_field?("term_external_id", with: "animal_1")

                switch_locale "ES"

                assert has_field?("term_name_translations_es", with: "Cabra")
                assert has_field?("term_description_translations_es", with: "La cabra es un animal")

                term = vocabulary.terms.last
                activity = Activity.last
                assert_equal term, activity.subject
                assert_equal admin, activity.author
                assert_equal site.id, activity.site_id
                assert_equal "gobierto_common.term_created", activity.action
              end
            end
          end
        end
      end
    end
  end
end
