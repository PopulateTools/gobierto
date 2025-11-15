# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  module GobiertoAdmin
    class UpdateTermTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_common_vocabulary_terms_path(vocabulary)
      end

      def vocabulary
        gobierto_common_vocabularies(:animals)
      end

      def vocabulary_associated_to_custom_fields
        gobierto_common_vocabularies(:madrid_political_groups_vocabulary)
      end

      def item_related_with_vocabulary
        @item_related_with_vocabulary ||= gobierto_investments_projects(:public_pool_project)
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

      def term
        @term ||= gobierto_common_terms(:dog)
      end

      def other_term
        @other_term ||= gobierto_common_terms(:cat)
      end

      def test_permissions
        with_signed_in_admin(unauthorized_admin) do
          with_current_site(site) do
            visit @path

            assert has_no_css?("#v_el_actions_#{term.id}")
          end
        end
      end

      def test_update_term
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within("#v_el_actions_#{term.id}", visible: false) do
                find_link("Edit", visible: false).execute_script("this.click()")
              end

              within "form.edit_term" do
                fill_in "term_name_translations_en", with: "Dog updated"
                fill_in "term_description_translations_en", with: "Dog description updated"
                fill_in "term_slug", with: "dog-updated"
                fill_in "term_external_id", with: "animal-updated"
                select other_term.name, from: "term_term_id"

                click_button "Update"
              end

              assert has_message?("Term updated successfully.")

              within("#v_el_actions_#{term.id}", visible: false) do
                find_link("Edit", visible: false).execute_script("this.click()")
              end

              assert has_field? "term_name_translations_en", with: "Dog updated"
              assert has_field? "term_description_translations_en", with: "Dog description updated"
              assert has_field? "term_slug", with: "dog-updated"
              assert has_field? "term_external_id", with: "animal-updated"
              assert has_select? "term_term_id", selected: "#{" " * 6} Cat"

              activity = Activity.last
              assert_equal term, activity.subject
              assert_equal admin, activity.author
              assert_equal site.id, activity.site_id
              assert_equal "gobierto_common.term_updated", activity.action
            end
          end
        end
      end

    end
  end
end
