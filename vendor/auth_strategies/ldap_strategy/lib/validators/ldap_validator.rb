# frozen_string_literal: true

require "net/ldap"

class LdapValidator < ActiveModel::Validator
  attr_reader :params, :site

  def validate(form)
    @params = form.data
    @site = form.site
    if (form.user_ldap_data = extract_user_ldap_data).blank?
      form.errors.add(:data, :invalid)
    end
  end

  def extract_user_ldap_data
    ldap_configurations.each do |ldap_configuration|
      ldap = initialize_ldap(ldap_configuration)
      ldap_entry = bind_ldap(ldap, ldap_configuration)

      return {
        email: ldap_field_value(ldap_entry, ldap_configuration.email_field),
        name: ldap_field_value(ldap_entry, ldap_configuration.name_field)
      } if ldap_entry.present?
    end

    nil
  end

  private

  def initialize_ldap(ldap_configuration)
    Net::LDAP.new.tap do |ldap|
      ldap.host = ldap_configuration.host
      ldap.port = ldap_configuration.port
      ldap.base = ldap_configuration.domain
      ldap.auth(ldap_username, ldap_password)
    end
  end

  def bind_ldap(ldap, ldap_configuration)
    ldap.bind_as(
      base: ldap_configuration.domain,
      filter: ldap_configuration.authentication_query.gsub("%{user_identifier}", username),
      password: password
    )
  end

  def username
    params[:user_session][:email]
  end

  def password
    params[:user_session][:password]
  end

  def ldap_field_value(ldap_entry, key)
    ldap_entry[0][key][0]
  end

  def ldap_password
    @ldap_password ||= Rails.application.secrets.ldap_configurations.dig(site.domain, "ldap_password")
  end

  def ldap_username
    @ldap_username ||= Rails.application.secrets.ldap_configurations.dig(site.domain, "ldap_username")
  end

  def ldap_configurations
    CollectionDecorator.new(Rails.application.secrets.ldap_configurations.dig(site.domain, "configurations") || [], decorator: OpenStruct)
  end
end
