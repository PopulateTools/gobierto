# frozen_string_literal: true

require "test_helper"

class User::SessionsControllerTest < GobiertoControllerTest
  def confirmed_user
    @confirmed_user ||= users(:dennis)
  end

  def other_site
    @other_site ||= sites(:santander)
  end

  def referrer_url
    "http://example.com/home"
  end

  def valid_session_params
    {
      email: confirmed_user.email,
      password: "gobierto"
    }
  end

  def test_create
    with_current_site(confirmed_user.site) do
      post(
        user_sessions_url,
        params: { user_session: valid_session_params }
      )
      assert_redirected_to root_path
    end
  end

  def test_create_in_other_site
    with_current_site(other_site) do
      post(
        user_sessions_url,
        params: { user_session: valid_session_params }
      )
      assert_response :success
      assert_equal "The data you entered doesn't seem to be valid. Please try again.",
        flash[:alert]
    end
  end

  def test_create_and_change_of_site
    with_current_site(confirmed_user.site) do
      post(
        user_sessions_url,
        params: { user_session: valid_session_params }
      )
    end
    with_current_site(other_site) do
      get(user_settings_url)
      assert_equal "Register or sign in if you have an account to continue.",
        flash[:alert]
    end
  end

  def test_create_with_referrer
    with_current_site(confirmed_user.site) do
      post(
        user_sessions_url,
        params: {
          user_session: valid_session_params.merge(referrer_url: referrer_url)
        }
      )
      assert_redirected_to referrer_url
    end
  end
end
