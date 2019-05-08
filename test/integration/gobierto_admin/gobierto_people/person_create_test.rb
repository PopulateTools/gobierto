# frozen_string_literal: true

require "test_helper"
require "support/integration/dynamic_content_helpers"
require "support/concerns/gobierto_admin/authorizable_resource_test_module"

module GobiertoAdmin
  module GobiertoPeople
    class PersonCreateTest < ActionDispatch::IntegrationTest

      include Integration::DynamicContentHelpers
      include ::GobiertoAdmin::AuthorizableResourceTestModule

      def setup
        super
        @path = new_admin_people_person_path
        setup_authorizable_resource_test(gobierto_admin_admins(:steve), @path)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def political_group
        @political_group ||= gobierto_common_terms(:marvel_term)
      end

      def content_context
        ::GobiertoPeople::Person.new
      end

      def test_person_create
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "form.new_person" do
                assert has_no_field?("person_charge_translations_ca", visible: false)

                within ".avatar_file_field" do
                  assert has_no_selector?("img")
                  attach_file "person_avatar_image", Rails.root.join("test/fixtures/files/gobierto_people/people/avatar.jpg")
                end
              end

              within "form.new_person" do
                fill_in "person_name", with: "Person Name"
                fill_in "Position", with: "Person Position"

                within ".person-category-radio-buttons" do
                  find("label", text: "Politician").click
                end

                within ".person-party-radio-buttons" do
                  find("label", text: "Government Team").click
                end

                select political_group.name, from: "Political group"

                within ".person-party-radio-buttons" do
                  find("label", text: "Government Team").click
                end

                # Simulate Bio rich text area
                page.execute_script('document.getElementById("person_bio_translations_en").value = "Person Bio"')

                within ".bio_file_field" do
                  assert has_no_selector?("a")
                  attach_file "person_bio_file", Rails.root.join("test/fixtures/files/gobierto_people/people/bio.pdf")
                end

                within ".widget_save" do
                  find("label", text: "Published").click
                end

                fill_in_content_blocks

                switch_locale "ES"

                fill_in "Position", with: "Cargo persona"
                page.execute_script('document.getElementById("person_bio_translations_es").value = "Bio Persona"')

                with_stubbed_s3_file_upload do
                  click_button "Create"
                end
              end

              assert has_message?("Person was successfully created. See the person.")
              assert has_selector?("h1", text: "Person Name")

              within "form.edit_person" do
                within ".avatar_file_field" do
                  assert has_selector?("img")
                end

                assert has_field?("person_name", with: "Person Name")
                assert has_field?("Position", with: "Person Position")

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
                    assert has_checked_field?("Published")
                  end
                end

                assert_content_blocks_have_the_right_values
                assert_content_blocks_can_be_managed

                switch_locale "ES"

                assert has_field?("Position", with: "Cargo persona")

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
