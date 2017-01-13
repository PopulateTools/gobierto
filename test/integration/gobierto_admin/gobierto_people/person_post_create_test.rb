require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonPostCreateTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = new_admin_people_person_post_path(person)
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

      def test_person_post_create
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "form.new_person_post" do
                fill_in "person_post_title", with: "Post Title"

                # Simulate Body rich text area
                find("#person_post_body", visible: false).set("Post Body")

                fill_in "person_post_tags", with: "one, two, three"

                within ".person-post-visibility-level-radio-buttons" do
                  find("label", text: "Active").click
                end

                click_button "Create Post"
              end

              assert has_message?("Post was successfully created")

              within "form.edit_person_post" do
                assert has_field?("person_post_title", with: "Post Title")

                assert_equal(
                  "<div>Post Body</div>",
                  find("#person_post_body", visible: false).value
                )

                assert has_field?("person_post_tags", with: "one, two, three")

                within ".person-post-visibility-level-radio-buttons" do
                  with_hidden_elements do
                    assert has_checked_field?("Active")
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
