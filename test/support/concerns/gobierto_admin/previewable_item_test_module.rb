# frozen_string_literal: true

module GobiertoAdmin
  module PreviewableItemTestModule

    def click_draft_checkbox
      find("label", text: "Draft").click
    rescue Capybara::ElementNotFound
      find("label", text: "Pending").click
    end

    def test_view_item_in_front
      with_signed_in_admin(admin) do
        with_current_site(site) do
          # when published
          visit preview_test_conf[:item_admin_path]

          within ".widget_save" do
            find("label", text: "Published").click
            click_button "Update"
          end

          within("header") { click_link "View item" }

          sleep 2

          assert current_url.include? preview_test_conf[:item_public_url]
          assert current_url.exclude? "preview_token=#{admin.preview_token}"

          # when draft
          visit preview_test_conf[:item_admin_path]

          within ".widget_save" do
            click_draft_checkbox
            click_button "Update"
          end

          within("header") { click_link "View item" }

          assert_equal "#{preview_test_conf[:item_public_url]}?preview_token=#{admin.preview_token}", current_url
        end
      end
    end

  end
end
