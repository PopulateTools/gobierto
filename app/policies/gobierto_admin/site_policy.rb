module GobiertoAdmin
  class SitePolicy
    attr_reader :admin, :site

    def initialize(admin, site = nil)
      @admin = admin
      @site = site
    end

    def view?
      manage?
    end

    def create?
      manage?
    end

    def update?
      manage?
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
