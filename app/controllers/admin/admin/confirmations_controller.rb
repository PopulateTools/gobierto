class Admin::Admin::ConfirmationsController < Admin::BaseController
  skip_before_action :authenticate_admin!

  layout "admin/sessions"

  def new
    @admin_confirmation_form = Admin::AdminConfirmationForm.new
  end

  def create
    @admin_confirmation_form = Admin::AdminConfirmationForm.new(admin_confirmation_params)

    if @admin_confirmation_form.save
      flash.now[:notice] = "Please check your inbox to get instructions."
    else
      flash.now[:alert] = "The email address specified doesn't seem to be valid."
    end

    render :new
  end

  def show
    admin = Admin.find_by(confirmation_token: params[:confirmation_token])

    if admin
      admin.confirm!
      admin.update_session_data(remote_ip)
      sign_in_admin(admin.id)
    else
      flash.now[:alert] = "This URL doesn't seem to be valid."
    end

    redirect_to admin_root_path
  end

  private

  def admin_confirmation_params
    params.require(:admin_confirmation).permit(:email)
  end
end
