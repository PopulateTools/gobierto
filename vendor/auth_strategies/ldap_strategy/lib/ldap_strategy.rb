# frozen_string_literal: true

require "active_support"

class LdapStrategy
  extend ActiveSupport::Autoload

  def self.eager_load!
    super
    require_relative "../app/forms/user/ldap_session_form"
  end
end
