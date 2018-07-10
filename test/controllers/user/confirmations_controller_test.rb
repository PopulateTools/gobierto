# frozen_string_literal: true

require "test_helper"

class User::ConfirmationsControllerTest < GobiertoControllerTest
  def unconfirmed_user_in_site
    @confirmed_user ||= users(:reed)
  end

  def unconfirmed_user_in_other_site
    @unconfirmed_user_in_other_site ||= users(:charles)
  end

  def site
    @site ||= sites(:madrid)
  end

  def other_site
    @other_site ||= sites(:santander)
  end

  def valid_session_params
    {
      email: confirmed_user.email,
      password: "gobierto"
    }
  end

  def test_unconfirmed_user_in_correct_site
    with_current_site(site) do
      get(new_user_confirmations_url(confirmation_token: unconfirmed_user_in_site.confirmation_token))
      assert_response :success
    end

    with_current_site(other_site) do
      get(new_user_confirmations_url(confirmation_token: unconfirmed_user_in_other_site.confirmation_token))
      assert_response :success
    end
  end

  def test_unconfirmed_user_in_wrong_site
    with_current_site(other_site) do
      get(new_user_confirmations_url(confirmation_token: unconfirmed_user_in_site.confirmation_token))
      assert_redirected_to root_path
      assert_equal "This URL doesn't seem to be valid",
        flash[:alert]
    end

    with_current_site(site) do
      get(new_user_confirmations_url(confirmation_token: unconfirmed_user_in_other_site.confirmation_token))
      assert_redirected_to root_path
      assert_equal "This URL doesn't seem to be valid",
        flash[:alert]
    end
  end
end
