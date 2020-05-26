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
      log_message("Connection initialized")
      ldap_entry = bind_ldap(ldap, ldap_server)
      log_message("LDAP bind result:\n #{ldap.get_operation_result.pretty_inspect}")

      if ldap_entry.present?
        log_message(
          %(
           Created LDAP entry with uid #{ldap_field_value(ldap_entry, :uid)},
           email #{ldap_field_value(ldap_entry, ldap_server.name_field)}
           and name #{ldap_field_value(ldap_entry, ldap_server.email_field)}
          )
        )
        return {
          email: ldap_field_value(ldap_entry, ldap_server.email_field),
          name: ldap_field_value(ldap_entry, ldap_server.name_field)
        }
      else
        log_message("LDAP entry creation failed")
      end
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

  def log_message(message)
    Rails.logger.info "[LDAP Strategy][LDAP Validator]#{message}"
  end
end
