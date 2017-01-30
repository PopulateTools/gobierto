require "test_helper"
require "support/integration/dynamic_content_helpers"
require "support/file_uploader_helpers"

module GobiertoAdmin
  module GobiertoPeople
    class PersonStatementCreateTest < ActionDispatch::IntegrationTest
      include Integration::DynamicContentHelpers
      include FileUploaderHelpers

      def setup
        super
        @path = new_admin_people_person_statement_path(person)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def content_context
        ::GobiertoPeople::PersonStatement.new
      end

      def test_person_statement_create
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "form.new_person_statement" do
                fill_in "person_statement_title", with: "Statement Title"
                fill_in "person_statement_published_on", with: "2017-01-01"

                within ".attachment_file_field" do
                  refute has_selector?("a")
                  attach_file "person_statement_attachment_file", "test/fixtures/files/gobierto_people/people/person_statement/attachment.pdf"
                end

                within ".person-statement-visibility-level-radio-buttons" do
                  find("label", text: "Published").click
                end

                fill_in_content_blocks

                with_stubbed_s3_file_upload do
                  click_button "Create"
                end
              end

              assert has_message?("Statement was successfully created. See the statement.")

              within "form.edit_person_statement" do
                assert has_field?("person_statement_title", with: "Statement Title")
                assert has_field?("person_statement_published_on", with: "2017-01-01")

                within ".attachment_file_field" do
                  assert has_selector?("a")
                end

                within ".person-statement-visibility-level-radio-buttons" do
                  with_hidden_elements do
                    assert has_checked_field?("Published")
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
