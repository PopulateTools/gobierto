# frozen_string_literal: true

module Authentication::AuthenticableTest
  def test_password_authentication
    assert user.authenticate("gobierto")
  end
end
