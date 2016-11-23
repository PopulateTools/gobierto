module User::VerificationHelper
  extend ActiveSupport::Concern

  private

  def user_verified?
    current_user.verified?
  end

  def require_no_verified_user
    raise_user_already_verified if user_verified?
  end

  def raise_user_already_verified
    redirect_to(
      request.referrer || user_root_path,
      alert: "You are already verified."
    )
  end
end
