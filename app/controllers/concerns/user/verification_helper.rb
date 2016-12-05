module User::VerificationHelper
  extend ActiveSupport::Concern

  private

  def verify_user_in!(site)
    raise_user_not_verified unless user_verified_in?(site)
  end

  def require_not_verified_user_in(site)
    raise_user_already_verified if user_verified_in?(site)
  end

  protected

  def user_verified_in?(site)
    User::VerificationService.new(current_user, site).call
  end

  def raise_user_already_verified
    redirect_to(
      request.referrer || user_root_path,
      alert: "You are already verified."
    )
  end

  def raise_user_not_verified
    redirect_to(
      new_user_census_verifications_path || request.referrer || user_root_path,
      alert: "Your account is not yet verified."
    )
  end
end
