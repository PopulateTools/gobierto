class Admin::BaseController < ApplicationController
  include SessionHelper
  include SiteSessionHelper

  before_action :authenticate_admin!

  helper_method :current_admin, :admin_signed_in?
  helper_method :current_site, :managing_site?
  helper_method :managed_sites

  layout "admin/application"
end
