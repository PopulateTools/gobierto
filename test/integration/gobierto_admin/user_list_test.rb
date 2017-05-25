# frozen_string_literal: true

require 'test_helper'

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

    def users_in_site
      @users_in_site ||= User.by_source_site(site)
    end

    def test_user_list
      with_signed_in_admin(signed_in_admin) do
        with_selected_site(site) do
          visit @path

          within 'table.user-list tbody' do
            users_in_site.each do |user|
              assert has_selector?("tr#user-item-#{user.id}")
            end
          end
        end
      end
    end
  end
end
