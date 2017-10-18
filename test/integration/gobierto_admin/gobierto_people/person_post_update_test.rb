# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/authorizable_resource_test_module"

module GobiertoAdmin
  module GobiertoPeople
    class PersonPostUpdateTest < ActionDispatch::IntegrationTest

      include ::GobiertoAdmin::AuthorizableResourceTestModule

      def setup
        super
        @path = edit_admin_people_person_post_path(person, person_post)
        setup_authorizable_resource_test(gobierto_admin_admins(:steve), @path)
      end

      def person_post
        @person_post ||= gobierto_people_person_posts(:richard_about_me)
      end

      def person
        @person ||= person_post.person
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_person_post_update
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "form.edit_person_post" do
                fill_in "person_post_title", with: "Post Title"

                # Simulate Body rich text area
                find("#person_post_body", visible: false).set("Post Body")

                fill_in "person_post_tags", with: "one, two, three"

                within ".widget_save" do
                  find("label", text: "Draft").click
                end

                click_button "Update"
              end

              assert has_message?("Post was successfully updated. See the post.")

              within "form.edit_person_post" do
                assert has_field?("person_post_title", with: "Post Title")

                assert_equal(
                  "<div>Post Body</div>",
                  find("#person_post_body", visible: false).value
                )

                assert has_field?("person_post_tags", with: "one, two, three")

                within ".widget_save" do
                  with_hidden_elements do
                    assert has_checked_field?("Draft")
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
