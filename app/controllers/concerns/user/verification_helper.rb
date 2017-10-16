module User::VerificationHelper
  extend ActiveSupport::Concern

  private

  def verify_user_in!(site)
    raise_user_not_verified(site) unless user_verified_in?(site)
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
      alert: t('user.census_verifications.messages.already_verified')
    )
  end

  def raise_user_not_verified(site)
    redirect_to(
      new_user_census_verifications_path || request.referrer || user_root_path,
      alert: t("user.census_verifications.messages.#{controller_name}.not_verified", site_name: site.try(:name))
    )
  end
end
