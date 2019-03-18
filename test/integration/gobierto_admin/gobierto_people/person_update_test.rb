# frozen_string_literal: true

require "test_helper"
require "support/integration/dynamic_content_helpers"
require "support/concerns/gobierto_admin/authorizable_resource_test_module"
require "support/concerns/gobierto_admin/previewable_item_test_module"

module GobiertoAdmin
  module GobiertoPeople
    class PersonUpdateTest < ActionDispatch::IntegrationTest
      include Integration::DynamicContentHelpers
      include ::GobiertoAdmin::AuthorizableResourceTestModule
      include ::GobiertoAdmin::PreviewableItemTestModule

      def setup
        super
        @path = edit_admin_people_person_path(person)
        setup_authorizable_resource_test(gobierto_admin_admins(:steve), @path)
        setup_specific_permissions(admin, module: "gobierto_people", person: person, site: site, reset: false)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end
      alias content_context person

      def admin
        @admin ||= person.admin
      end

      def site
        @site ||= person.site
      end

      def political_group
        @political_group ||= gobierto_common_terms(:marvel_term)
      end

      def preview_test_conf
        {
          item_admin_path: edit_admin_people_person_path(person),
          item_public_url: person.to_url
        }
      end

      def test_person_update
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "form.edit_person" do
                within ".avatar_file_field" do
                  attach_file "person_avatar_image", "test/fixtures/files/gobierto_people/people/avatar-small.jpg"
                end
              end

              within "form.edit_person" do
                fill_in "person_name", with: "Person Name"
                fill_in "person_charge_translations_en", with: "Person Position"

                within ".person-category-radio-buttons" do
                  find("label", text: "Politician").click
                end

                within ".person-party-radio-buttons" do
                  find("label", text: "Government Team").click
                end

                select political_group.name, from: "Political group"

                # Simulate Bio rich text area
                find("#person_bio_translations_en", visible: false).set("Person Bio")

                within ".bio_file_field" do
                  attach_file "person_bio_file", "test/fixtures/files/gobierto_people/people/bio.pdf"
                end

                within ".widget_save" do
                  find("label", text: "Draft").click
                end

                fill_in_content_blocks

                click_link "ES"

                fill_in "person_charge_translations_es", with: "Cargo persona"
                find("#person_bio_translations_es", visible: false).set("Bio Persona")

                with_stubbed_s3_file_upload do
                  click_button "Update"
                end
              end

              assert has_message?("Person was successfully updated. See the person.")

              within "form.edit_person" do
                within ".avatar_file_field" do
                  assert has_selector?("img")
                end

                assert has_field?("person_name", with: "Person Name")
                assert has_field?("person_charge_translations_en", with: "Person Position")

                within ".person-category-radio-buttons" do
                  with_hidden_elements do
                    assert has_checked_field?("Politician")
                  end
                end

                within ".person-party-radio-buttons" do
                  with_hidden_elements do
                    assert has_checked_field?("Government Team")
                  end
                end

                assert has_select?("Political group", selected: political_group.name)

                assert_equal(
                  "Person Bio",
                  find("#person_bio_translations_en", visible: false).value
                )

                within ".bio_file_field" do
                  assert has_selector?("a")
                end

                within ".widget_save" do
                  with_hidden_elements do
                    assert has_checked_field?("Draft")
                  end
                end
                assert_content_blocks_have_the_right_values
                assert_content_blocks_can_be_managed

                click_link "ES"

                assert has_field?("person_charge_translations_es", with: "Cargo persona")

                assert_equal(
                  "Bio Persona",
                  find("#person_bio_translations_es", visible: false).value
                )
              end
            end
          end
        end
      end
    end
  end
end
