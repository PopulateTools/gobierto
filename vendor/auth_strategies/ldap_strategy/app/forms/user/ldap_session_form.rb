# frozen_string_literal: true

class User::LdapSessionForm < User::CustomSessionForm

  attr_accessor(
    :email,
    :password,
    :user_ldap_data
  )

  validates_with LdapValidator

  def save
    return false if authentication_data_invalid?

    find_or_create_user
  end

  def authentication_data_invalid?
    !valid? && user_ldap_data.blank?
  end

  def find_or_create_user
    @user = site.users.find_by(user_ldap_data.slice(:email)) || site.users.new(user_ldap_data)

    send_confirmation_instructions if user.new_record? && user.save
    user
  end

  def send_confirmation_instructions
    user.regenerate_confirmation_token
    deliver_confirmation_email
  end

  protected

  def deliver_confirmation_email
    User::UserMailer.confirmation_instructions(user, site).deliver_later
  end
end
