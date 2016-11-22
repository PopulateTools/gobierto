class Admin::Admin::PasswordsController < Admin::BaseController
  skip_before_action :authenticate_admin!
  before_action :require_no_authentication

  layout "admin/sessions"

  def new
    @admin_password_form = Admin::AdminNewPasswordForm.new
  end

  def create
    @admin_password_form = Admin::AdminNewPasswordForm.new(admin_new_password_params)

    if @admin_password_form.save
      flash.now[:notice] = "Please check your inbox to get instructions."
    else
      flash.now[:alert] = "The email address specified doesn't seem to be valid."
    end

    render :new
  end

  def edit
    admin = Admin.find_by(reset_password_token: params[:reset_password_token])

    if admin
      @admin_password_form = Admin::AdminEditPasswordForm.new(admin_id: admin.id)
    else
      flash.now[:alert] = "This URL doesn't seem to be valid."
      redirect_to admin_root_path
    end
  end

  def update
    @admin_password_form = Admin::AdminEditPasswordForm.new(
      admin_edit_password_params
    )

    if @admin_password_form.save
      admin = @admin_password_form.admin

      admin.recovered!
      admin.update_session_data(remote_ip)
      sign_in_admin(admin.id)

      redirect_to(after_sign_in_path, notice: "Signed in successfully.")
    else
      flash[:notice] = "There was a problem changing your password."
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
