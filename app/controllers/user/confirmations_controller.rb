class User::ConfirmationsController < User::BaseController
  before_action :require_no_authentication

  def new
    @user_confirmation_form = User::ConfirmationForm.new(
      confirmation_token: params[:confirmation_token]
    )
    @user_genders = get_user_genders
    @user_years_of_birth = get_user_years_of_birth

    unless @user_confirmation_form.user
      redirect_to root_path, alert: t(".error")
    end
  end

  def create
    @user_confirmation_form = User::ConfirmationForm.new(
      user_confirmation_params
    )

    if @user_confirmation_form.save
      user = @user_confirmation_form.user

      user.update_session_data(remote_ip)
      sign_in_user(user.id)

      redirect_to after_sign_in_path, notice: t(".success")
    else
      @user_genders = get_user_genders
      @user_years_of_birth = get_user_years_of_birth

      flash.now[:alert] = t(".error")
      render :new
    end
  end

  private

  def user_confirmation_params
    params.require(:user_confirmation).permit(
      :confirmation_token,
      :name,
      :password,
      :password_confirmation,
      :year_of_birth,
      :gender
    )
  end

  def get_user_genders
    User.genders
  end

  def get_user_years_of_birth
    (18.years.ago.year..Date.current.year)
  end
end
