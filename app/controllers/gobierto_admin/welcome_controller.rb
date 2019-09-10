# frozen_string_literal: true

module GobiertoAdmin
  class WelcomeController < BaseController
    def index
      unless current_admin.managing_user?
        module_path = if (available_modules = current_admin.modules_permissions.where(resource_type: default_modules_home_paths.keys).on_site(current_site)).exists?
                        default_modules_home_paths[available_modules.first.resource_type]
                      else
                        edit_admin_admin_settings_path
                      end
        redirect_to module_path and return
      end

      @activities = ActivityCollectionDecorator.new(
        Activity.where(site_id: current_site).or(Activity.where(site_id: nil)).sorted.includes(:subject, :author, :recipient).page(params[:page])
      )
      render "gobierto_admin/activities/index"
    end
  end
end
