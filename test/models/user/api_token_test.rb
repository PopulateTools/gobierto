# frozen_string_literal: true

require "test_helper"

class User::ApiTokenTest < ActiveSupport::TestCase
  def user_primary_api_token
    @user_primary_api_token ||= user_api_tokens(:dennis_primary_api_token)
  end

  def test_valid
    assert user_primary_api_token.valid?
  end

  def test_to_s
    assert_equal user_primary_api_token.token, "#{user_primary_api_token}"
  end
end
