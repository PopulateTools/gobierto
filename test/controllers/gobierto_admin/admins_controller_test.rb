require "test_helper"

module GobiertoAdmin
  class AdminsControllerTest < GobiertoControllerTest
    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def setup
      super
      sign_in_admin(admin)
    end

    def teardown
      super
      sign_out_admin
    end

    def valid_admin_params
      {
        admin: {
          name: admin.name,
          email: admin.email
        }
      }
    end

    def test_edit
      get edit_admin_admin_url(admin)
      assert_response :success
    end

    def test_update
      patch admin_admin_url(admin), params: valid_admin_params
      assert_redirected_to edit_admin_admin_path(admin)
    end
  end
end
