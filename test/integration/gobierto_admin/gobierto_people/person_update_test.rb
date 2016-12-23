require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonUpdateTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = edit_admin_people_person_path(person)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def admin
        @admin ||= person.admin
      end

      def site
        @site ||= person.site
      end

      def test_person_update
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "form.edit_person" do
              fill_in "person_name", with: "Person Name"
              fill_in "person_charge", with: "Person Charge"
              fill_in "person_bio", with: "Person Bio"
              fill_in "person_bio_url", with: "Person Bio URL"

              within ".person-visibility-level-radio-buttons" do
                choose "Draft"
              end

              click_button "Update Person"
            end

            assert has_message?("Person was successfully updated")

            within "form.edit_person" do
              assert has_field?("person_name", with: "Person Name")
              assert has_field?("person_charge", with: "Person Charge")
              assert has_field?("person_bio", with: "Person Bio")
              assert has_field?("person_bio_url", with: "Person Bio URL")

              within ".person-visibility-level-radio-buttons" do
                assert has_checked_field?("Draft")
              end
            end
          end
        end
      end
    end
  end
end
