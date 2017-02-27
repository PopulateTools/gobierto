class User::CensusVerificationsController < User::BaseController
  before_action :authenticate_user!
  before_action(only: [:new, :create]) { require_not_verified_user_in(current_site) }

  def new
    @user_verification_form = User::CensusVerificationForm.new(site_id: current_site.id, referrer_url: request.referrer)
  end

  def create
    @user_verification_form = User::CensusVerificationForm.new(
      user_verification_params.except(*ignored_user_verification_params).merge(
        date_of_birth_year: user_verification_params["date_of_birth(1i)"],
        date_of_birth_month: user_verification_params["date_of_birth(2i)"],
        date_of_birth_day: user_verification_params["date_of_birth(3i)"],
        user_id: current_user.id,
        creation_ip: remote_ip,
        site_id: current_site.id
      )
    )

    if @user_verification_form.save && @user_verification_form.user.census_verified?
      redirect_to(
        @user_verification_form.referrer_url.present? ?  @user_verification_form.referrer_url : user_settings_path,
        notice: t('.notice')
      )
    else
      flash.now[:alert] = t('.error')
      render :new
    end
  end

  private

  def user_verification_params
    params.require(:user_verification).permit(:document_number, :date_of_birth, :site_id, :referrer_url)
  end

  def ignored_user_verification_params
    ["date_of_birth(1i)", "date_of_birth(2i)", "date_of_birth(3i)"]
  end
end
