class Admin::Admin::ConfirmationsController < Admin::BaseController
  skip_before_action :authenticate_admin!

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
end
