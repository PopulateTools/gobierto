require "test_helper"

class User::SessionsControllerTest < GobiertoControllerTest
  def confirmed_user
    @confirmed_user ||= users(:dennis)
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
    post(
      user_sessions_url,
      params: { user_session: valid_session_params }
    )
    assert_redirected_to root_path
  end

  def test_create_with_referrer
    post(
      user_sessions_url,
      params: {
        user_session: valid_session_params.merge(referrer_url: referrer_url)
      }
    )
    assert_redirected_to referrer_url
  end
end
