# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminGroupTest < ActiveSupport::TestCase
    def site
      @site ||= sites(:madrid)
    end

    def other_site
      @other_site ||= sites(:santander)
    end

    def admin_group
      @admin_group ||= gobierto_admin_admin_groups(:madrid_group)
    end

    def other_site_admin_group
      @other_site_admin_group ||= gobierto_admin_admin_groups(:santander_group)
    end

    def test_valid
      assert admin_group.valid?
      assert other_site_admin_group.valid?
    end
  end
end
