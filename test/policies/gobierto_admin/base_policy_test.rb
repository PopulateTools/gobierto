# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  class BasePolicyTest < ActiveSupport::TestCase

    def manager_admin
      @manager_admin ||= gobierto_admin_admins(:nick)
    end

    def regular_admin
      @regular_admin ||= gobierto_admin_admins(:tony)
    end

    def disabled_admin
      @disabled_admin ||= gobierto_admin_admins(:podrick)
    end

    def test_manage?
      assert BasePolicy.new(current_admin: manager_admin).manage?
      assert_nil BasePolicy.new(current_admin: regular_admin).manage?
      refute BasePolicy.new(current_admin: disabled_admin).manage?
    end

  end
end
