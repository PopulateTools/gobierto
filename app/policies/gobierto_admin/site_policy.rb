# frozen_string_literal: true

module GobiertoAdmin
  class SitePolicy
    attr_reader :admin, :site

    def initialize(admin, site = nil)
      @admin = admin
      @site = site
    end

    def list?
      manage?
    end

    def create?
      manage?
    end

    def update?
      admin.can_customize_site?
    end

    def delete?
      manage?
    end

    private

    def manage?
      admin.managing_user?
    end
  end
end
