# frozen_string_literal: true

require "net/ldap"

class LdapValidator < ActiveModel::Validator
  attr_reader :params, :site

  def validate(form)
    @params = form.data
    @site = form.site
    if (form.ldap_data = extract_user_ldap_data).blank?
      form.errors.add(:data, :invalid)
    end
  end

  def extract_user_ldap_data
    ldap_servers.each do |ldap_server|
      ldap = initialize_ldap(ldap_server)
      ldap_entry = bind_ldap(ldap, ldap_server)

      return {
        email: ldap_field_value(ldap_entry, ldap_server.email_field),
        name: ldap_field_value(ldap_entry, ldap_server.name_field)
      } if ldap_entry.present?
    end

    nil
  end

  private

  def initialize_ldap(ldap_server)
    Net::LDAP.new.tap do |ldap|
      ldap.host = ldap_server.host
      ldap.port = ldap_server.port
      ldap.base = ldap_server.domain
      ldap.auth(ldap_username, ldap_password)
    end
  end

  def bind_ldap(ldap, ldap_server)
    ldap.bind_as(
      base: ldap_server.domain,
      filter: ldap_server.authentication_query.gsub("@screen_name@", username),
      password: password
    )
  end

  def username
    params[:session][:identifier]
  end

  def password
    params[:session][:password]
  end

  def ldap_field_value(ldap_entry, key)
    ldap_entry[0][key][0]
  end

  def ldap_password
    @ldap_password ||= ldap_configuration.dig("ldap_password")
  end

  def ldap_username
    @ldap_username ||= ldap_configuration.dig("ldap_username")
  end

  def ldap_servers
    CollectionDecorator.new(ldap_configuration.fetch("configurations", []), decorator: OpenStruct)
  end

  def ldap_configuration
    @ldap_configuration || site.configuration.configuration_variables["ldap"] || {}
  end
end
