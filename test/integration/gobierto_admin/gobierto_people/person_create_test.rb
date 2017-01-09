require "test_helper"
require "support/integration/dynamic_content_helpers"
require "support/file_uploader_helpers"

module GobiertoAdmin
  module GobiertoPeople
    class PersonCreateTest < ActionDispatch::IntegrationTest
      include Integration::DynamicContentHelpers
      include FileUploaderHelpers

      def setup
        super
        @path = new_admin_people_person_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
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
                within ".avatar_file_field" do
                  refute has_selector?("img")
                  attach_file "person_avatar_file", "test/fixtures/files/gobierto_people/people/avatar.jpg"
                end

                fill_in "person_name", with: "Person Name"
                fill_in "person_charge", with: "Person Charge"

                # Simulate Bio rich text area
                find("#person_bio", visible: false).set("Person Bio")

                within ".bio_file_field" do
                  refute has_selector?("a")
                  attach_file "person_bio_file", "test/fixtures/files/gobierto_people/people/bio.pdf"
                end

                within ".person-visibility-level-radio-buttons" do
                  find("label", text: "Active").click
                end

                fill_in_content_blocks

                with_stubbed_s3_file_upload do
                  click_button "Create Person"
                end
              end

              assert has_message?("Person was successfully created")
              assert has_selector?("h1", text: "Person Name")

              within "form.edit_person" do
                within ".avatar_file_field" do
                  assert has_selector?("img")
                end

                assert has_field?("person_name", with: "Person Name")
                assert has_field?("person_charge", with: "Person Charge")

                assert_equal(
                  "<div>Person Bio</div>",
                  find("#person_bio", visible: false).value
                )

                within ".bio_file_field" do
                  assert has_selector?("a")
                end

                within ".person-visibility-level-radio-buttons" do
                  with_hidden_elements do
                    assert has_checked_field?("Active")
                  end
                end

                assert_content_blocks_have_the_right_values
                assert_content_blocks_can_be_managed
              end
            end
          end
        end
      end
    end
  end
end
