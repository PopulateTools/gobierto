# frozen_string_literal: true

class User::BaseController < ApplicationController
  include User::SessionHelper
  include User::VerificationHelper

  helper_method :registration_disabled?

  layout "user/layouts/application"

  def registration_disabled?
    current_site.configuration.registration_disabled?
  end

  private

  def read_only_user_attributes
    return [] unless auth_modules_present?

    @read_only_user_attributes ||= current_site.configuration.auth_modules_data.inject([]) do |attributes, auth_module|
      attributes | (auth_module.read_only_user_attributes || [])
    end
  end

  def check_registration_enabled
    raise_user_not_authorized if registration_disabled?
  end
end
