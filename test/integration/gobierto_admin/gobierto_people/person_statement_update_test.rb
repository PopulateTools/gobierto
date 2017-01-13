require "test_helper"
require "support/integration/dynamic_content_helpers"

module GobiertoAdmin
  module GobiertoPeople
    class PersonStatementUpdateTest < ActionDispatch::IntegrationTest
      include Integration::DynamicContentHelpers

      def setup
        super
        @path = edit_admin_people_person_statement_path(person, person_statement)
      end

      def person_statement
        @person_statement ||= gobierto_people_person_statements(:richard_current)
      end
      alias content_context person_statement

      def person
        @person ||= person_statement.person
      end

      def admin
        @admin ||= person.admin
      end

      def site
        @site ||= person.site
      end

      def test_person_statement_update
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "form.edit_person_statement" do
                fill_in "person_statement_title", with: "Statement Title"
                fill_in "person_statement_published_on", with: "2017-01-01"

                within ".person-statement-visibility-level-radio-buttons" do
                  find("label", text: "Draft").click
                end

                fill_in_content_blocks

                click_button "Update Statement"
              end

              assert has_message?("Statement was successfully updated")

              within "form.edit_person_statement" do
                assert has_field?("person_statement_title", with: "Statement Title")
                assert has_field?("person_statement_published_on", with: "2017-01-01")

                within ".person-statement-visibility-level-radio-buttons" do
                  with_hidden_elements do
                    assert has_checked_field?("Draft")
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
