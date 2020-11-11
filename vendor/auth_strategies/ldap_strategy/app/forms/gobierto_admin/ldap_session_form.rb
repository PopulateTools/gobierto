# frozen_string_literal: true

class GobiertoAdmin::LdapSessionForm < GobiertoAdmin::CustomSessionForm

  attr_accessor(
    :identifier,
    :password,
    :ldap_data
  )

  validates_with LdapValidator, unless: :session_default_strategy

  def initialize(attributes = {})
    @identifier = attributes.dig(:data, :session, :identifier)
    @password = attributes.dig(:data, :session, :password)

    super(attributes)
  end

  def save
    return session_default_strategy if authentication_data_invalid?

    find_or_create_admin_by_ldap
  end

  def authentication_data_invalid?
    !valid? && ldap_data.blank?
  end

  def find_or_create_admin_by_ldap
    @admin = GobiertoAdmin::Admin.active.find_by(ldap_data.slice(:email)) || new_admin(ldap_data)

    if admin.new_record? && admin.save || admin.regular? && admin.sites.exclude?(site)
      admin.sites << site
    end
    admin
  end

  def session_default_strategy
    @admin ||= GobiertoAdmin::Admin.with_password.active.find_by(email: identifier.downcase)&.authenticate(password)
  end

  def new_admin(ldap_data)
    GobiertoAdmin::Admin.regular.new(ldap_data)
  end
end
