# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class UserListTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = admin_users_path
    end

    def signed_in_admin
      @signed_in_admin ||= gobierto_admin_admins(:nick)
    end

    def user
      @user ||= users(:reed)
    end

    def site
      @site ||= sites(:madrid)
    end

    def other_site
      @other_site ||= sites(:santander)
    end

    def users_in_site
      @users_in_site ||= User.by_site(site)
    end

    def users_in_other_site
      @users_in_other_site ||= User.by_site(other_site)
    end

    def test_user_list
      with_signed_in_admin(signed_in_admin) do
        with_selected_site(site) do
          visit @path

          within "table.user-list tbody" do
            users_in_site.each do |user|
              assert has_selector?("tr#user-item-#{user.id}")
            end
            users_in_other_site.each do |user|
              assert has_no_selector?("tr#user-item-#{user.id}")
            end
          end
        end
      end
    end
  end
end
