# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class UserShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = admin_user_path(user)
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def user
      @user ||= users(:reed)
    end

    def site
      @site ||= user.site
    end

    def test_user_show
      with_signed_in_admin(admin) do
        with_selected_site(site) do
          visit @path

          within ".admin_content" do
            assert has_content?(user.name)
            assert has_link?(user.email)
          end
        end
      end
    end
  end
end
