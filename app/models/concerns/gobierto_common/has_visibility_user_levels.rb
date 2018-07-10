module GobiertoCommon
  module HasVisibilityUserLevels
    extend ActiveSupport::Concern

    included do
      enum visibility_user_level: { registered: 0, verified: 1 }
      validates :visibility_user_level, presence: true
    end

    def visibility_level_allowed_for?(user)
      return false if user.blank?

      if registered?
        user.try :confirmed?
      elsif verified?
        user.try(:verified_in_site?, site)
      else
        user.try(:verified_in_site_with_level?, site, visibility_user_level)
      end
    end

  end
end
