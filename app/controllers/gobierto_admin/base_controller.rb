module GobiertoAdmin
  class BaseController < ApplicationController
    include SessionHelper
    include SiteSessionHelper
    include LayoutPolicyHelper
    include ModuleHelper

    before_action :authenticate_admin!

    helper_method :current_admin, :admin_signed_in?
    helper_method :current_site, :managing_site?
    helper_method :managed_sites
    helper_method :can_manage_sites?

    rescue_from Errors::NotAuthorized, with: :raise_admin_not_authorized

    layout "gobierto_admin/layouts/application"
  end
end
