module GobiertoAdmin
  class Admin::PasswordsController < BaseController
    skip_before_action :authenticate_admin!, raise: false
    before_action :require_no_authentication

    helper_method :site_from_domain

    layout "gobierto_admin/layouts/sessions"

    def new
      @admin_password_form = AdminNewPasswordForm.new
    end

    def create
      @admin_password_form = AdminNewPasswordForm.new(admin_new_password_params)

      if @admin_password_form.save
        flash.now[:notice] = t(".success")
      else
        flash.now[:alert] = t(".error")
      end

      render :new
    end

    def edit
      admin = Admin.find_by_reset_password_token(params[:reset_password_token])

      if admin
        @admin_password_form = AdminEditPasswordForm.new(admin_id: admin.id)
      else
        redirect_to admin_root_path, alert: t(".error")
      end
    end

    def update
      @admin_password_form = AdminEditPasswordForm.new(
        admin_edit_password_params
      )

      if @admin_password_form.save
        admin = @admin_password_form.admin

        admin.recovered!
        admin.update_session_data(remote_ip)
        sign_in_admin(admin.id)

        redirect_to after_sign_in_path, notice: t(".success")
      else
        flash[:notice] = t(".error")
        render :edit
      end
    end

    private

    def admin_new_password_params
      params.require(:admin_password).permit(
        :email
      )
    end

    def admin_edit_password_params
      params.require(:admin_password).permit(
        :admin_id,
        :password,
        :password_confirmation
      )
    end
  end
end
