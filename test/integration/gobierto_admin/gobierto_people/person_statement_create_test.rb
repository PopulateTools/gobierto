require "test_helper"
require "support/integration/dynamic_content_helpers"

module GobiertoAdmin
  module GobiertoPeople
    class PersonStatementCreateTest < ActionDispatch::IntegrationTest
      include Integration::DynamicContentHelpers

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

                within ".person-statement-visibility-level-radio-buttons" do
                  find("label", text: "Active").click
                end

                fill_in_content_blocks

                click_button "Create Statement"
              end

              assert has_message?("Statement was successfully created")

              within "form.edit_person_statement" do
                assert has_field?("person_statement_title", with: "Statement Title")
                assert has_field?("person_statement_published_on", with: "2017-01-01")

                within ".person-statement-visibility-level-radio-buttons" do
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
