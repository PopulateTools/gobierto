# frozen_string_literal: true

module SiteConfigHelpers
  def with_auth_modules_for_domains(domains)
    Object.stub_const(:AUTH_MODULES, AUTH_MODULES.map { |auth_module| auth_module.tap { |attrs| attrs.domains = domains } }) do
      yield
    end
  end

  def with_auth_modules_disabled_password
    Object.stub_const(:AUTH_MODULES, AUTH_MODULES.map { |auth_module| auth_module.tap { |attrs| attrs.password_enabled = false } }) do
      yield
    end
  end
end
