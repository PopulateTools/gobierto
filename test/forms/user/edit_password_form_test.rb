# frozen_string_literal: true

require "test_helper"

class User::EditPasswordFormTest < ActiveSupport::TestCase
  def valid_user_edit_password_form
    @valid_user_edit_password_form ||= User::EditPasswordForm.new(
      user_id: user.id,
      site: site,
      password: "wadus",
      password_confirmation: "wadus"
    )
  end

  def invalid_user_edit_password_form
    @invalid_user_edit_password_form ||= User::EditPasswordForm.new(
      user_id: other_site_user.id,
      site: site,
      password: "wadus",
      password_confirmation: "wadus"
    )
  end

  def site
    @site ||= sites(:madrid)
  end

  def user
    @user ||= users(:reed)
  end

  def other_site_user
    @other_site_user ||= users(:charles)
  end

  def test_validation
    assert valid_user_edit_password_form.valid?
    refute invalid_user_edit_password_form.valid?
  end

  def test_save
    assert valid_user_edit_password_form.save
  end
end
