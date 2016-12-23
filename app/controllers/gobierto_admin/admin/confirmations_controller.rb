module GobiertoAdmin
  class Admin::ConfirmationsController < BaseController
    skip_before_action :authenticate_admin!
    before_action :require_no_authentication

    layout "gobierto_admin/layouts/sessions"

    def new
      @admin_confirmation_form = AdminConfirmationForm.new
    end

    def create
      @admin_confirmation_form = AdminConfirmationForm.new(admin_confirmation_params)

      if @admin_confirmation_form.save
        flash.now[:notice] = t(".success")
      else
        flash.now[:alert] = t(".error")
      end

      render :new
    end

    def show
      # TODO. Consider extracting this whole action into a service object.
      #
      admin = Admin.find_by_confirmation_token(params[:confirmation_token])

      if admin
        admin.confirm!
        admin.update_session_data(remote_ip)
        sign_in_admin(admin.id)

        redirect_to after_sign_in_path, notice: t(".success")
      else
        redirect_to admin_root_path, alert: t(".error")
      end
    end

    private

    def admin_confirmation_params
      params.require(:admin_confirmation).permit(:email)
    end
  end
end
