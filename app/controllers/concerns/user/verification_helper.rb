module User::VerificationHelper
  extend ActiveSupport::Concern

  private

  def check_visibility_level(resource, user)
    unless resource.visibility_level_allowed_for?(user)
      #raise_visibility_forbidden(resource, user)
    end
  end

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

  def raise_visibility_forbidden(resource, user)
    case resource.visibility_user_level
    when 'verified'
      raise_user_not_verified(resource.site)
    when 'registered'
      raise_user_not_signed_in
    end
  end

  def raise_user_not_verified(site)
    redirect_to(
      new_user_census_verifications_path || request.referrer || user_root_path,
      alert: t("user.census_verifications.messages.#{controller_name}.not_verified", site_name: site.try(:name))
    )
  end
end
