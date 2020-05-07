# frozen_string_literal: true

class User::LdapSessionForm < User::CustomSessionForm

  attr_accessor(
    :email,
    :password,
    :user_ldap_data
  )

  validates_with LdapValidator, unless: :session_default_strategy

  def initialize(attributes = {})
    @email = attributes.dig(:data, :user_session, :email)
    @password = attributes.dig(:data, :user_session, :password)

    super(attributes)
  end

  def save
    return session_default_strategy if authentication_data_invalid?

    find_or_create_user_by_ldap
  end

  def authentication_data_invalid?
    !valid? && user_ldap_data.blank?
  end

  def find_or_create_user_by_ldap
    @user = site.users.find_by(user_ldap_data.slice(:email)) || site.users.new(user_ldap_data)

    user.confirm! if user.new_record? && user.save || !user.confirmed?
    user
  end

  def session_default_strategy
    @user ||= User::SessionForm.new(email: email, password: password, site: site).save
  end
end
