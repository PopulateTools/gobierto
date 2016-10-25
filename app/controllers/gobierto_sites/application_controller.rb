class GobiertoSites::ApplicationController < ApplicationController
  layout 'gobierto_site_application'

  before_action :authenticate_user_in_site

  private

  def authenticate_user_in_site
    if Rails.env.production? && @site && @site.password_protected?
      authenticate_or_request_with_http_basic('Gobierto Site') do |username, password|
        username == @site.configuration.password_protection_username && password == @site.configuration.password_protection_password
      end
    end
  end
end
