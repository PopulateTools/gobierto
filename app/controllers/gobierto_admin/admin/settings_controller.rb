module GobiertoAdmin
  class Admin::SettingsController < BaseController
    before_action :authenticate_admin!

    def edit
      @admin_settings_form = AdminSettingsForm.new({
        id: current_admin.id, name: current_admin.name,
        email: current_admin.email
      })

      set_api_tokens
    end

    def update
      @admin_settings_form = AdminSettingsForm.new(id: current_admin.id)
      @admin_settings_form.assign_attributes(admin_settings_params.except(*ignored_admin_settings_params))
      set_api_tokens

      if @admin_settings_form.save
        flash[:notice] = t(".success")
        redirect_to edit_admin_admin_settings_path
      else
        flash[:alert] = t(".error")
        render 'edit'
      end
    end

    private

    def admin_settings_params
      params.require(:admin).permit(:name, :email, :password, :password_confirmation)
    end

    def get_user_genders
      User.genders
    end

    def set_api_tokens
      @api_tokens = current_admin.api_tokens
    end

    def ignored_admin_settings_params
      []
    end
  end
end
