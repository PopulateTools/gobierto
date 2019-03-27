# frozen_string_literal: true

class User::VerificationService
  attr_reader :user, :site, :verification_type

  def initialize(user, site, verification_type = "census")
    @user = user
    @site = site
    @verification_type = verification_type
  end

  def call
    return false unless User::Verification.respond_to?(verification_type)

    User::Verification
      .send(verification_type)
      .where(user_id: user.id)
      .current_by_site(site)
      .try(:verified?)
  end
end
