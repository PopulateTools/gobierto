require "test_helper"

module GobiertoAdmin
  class UsersControllerTest < GobiertoControllerTest
    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def user
      @user ||= users(:dennis)
    end

    def setup
      super
      sign_in_admin(admin)
    end

    def teardown
      super
      sign_out_admin
    end

    def valid_user_params
      {
        user: {
          name: user.name,
          email: user.email
        }
      }
    end

    def test_edit
      get edit_admin_user_url(user)
      assert_response :success
    end

    def test_update
      patch admin_user_url(user), params: valid_user_params
      assert_redirected_to edit_admin_user_path(user)
    end
  end
end
