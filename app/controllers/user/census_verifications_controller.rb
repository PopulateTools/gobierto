class User::CensusVerificationsController < User::BaseController
  before_action :authenticate_user!
  before_action(only: [:new, :create]) { require_not_verified_user_in(current_site) }

  def show
    @user_verifications = current_user.census_verifications.sorted
  end

  def new
    @user_verification_form = User::CensusVerificationForm.new(site_id: current_site.id)
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

    if @user_verification_form.save
      redirect_to(
        user_census_verifications_path,
        notice: t('.notice')
      )
    else
      flash.now[:alert] = t('.error')
      render :new
    end
  end

  private

  def user_verification_params
    params.require(:user_verification).permit(
      :document_number,
      :date_of_birth,
      :site_id
    )
  end

  def ignored_user_verification_params
    ["date_of_birth(1i)", "date_of_birth(2i)", "date_of_birth(3i)"]
  end
end
