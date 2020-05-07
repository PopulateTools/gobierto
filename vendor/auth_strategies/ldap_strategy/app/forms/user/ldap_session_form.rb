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

    user.confirm! if user.new_record? && user.save || !user.confirmed?
    user
  end
end
