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
              fill_in "person_bio", with: "Person Bio"

              within ".bio_file_field" do
                refute has_selector?("a")
                attach_file "person_bio_file", "test/fixtures/files/gobierto_people/people/bio.pdf"
              end

              within ".person-visibility-level-radio-buttons" do
                choose "Active"
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
              assert has_field?("person_bio", with: "Person Bio")

              within ".bio_file_field" do
                assert has_selector?("a")
              end

              within ".person-visibility-level-radio-buttons" do
                assert has_checked_field?("Active")
              end

              assert_content_blocks_have_the_right_values
            end
          end
        end
      end
    end
  end
end
