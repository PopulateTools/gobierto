# frozen_string_literal: true

module GobiertoAdmin
  class Users::UsersStatsPresenter
    def initialize(site)
      @site = site
    end

    def total_users
      @total_users ||= users_scope.count
    end

    def total_verified
      @total_verified ||= users_scope.census_verified.count
    end

    def total_confirmed
      @total_pending_verification ||= users_scope.where(confirmation_token: nil).count
    end

    def total_verified_percentage
      ((total_verified / total_users.to_f) * 100).round(1)
    end

    def total_confirmed_percentage
      ((total_confirmed / total_users.to_f) * 100).round(1)
    end

    private

    def users_scope
      User.by_site(@site)
    end
  end
end
