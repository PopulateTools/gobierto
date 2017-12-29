# frozen_string_literal: true

module GobiertoCommon
  module HasVisibilityUserLevelsTest

    def setup_visibility_user_levels_test(opts = {}) #registered_level_user, verified_level_user, registered_level_resource, verified_level_resource)
      @registered_level_user ||= opts[:registered_level_user]
      @verified_level_user ||= opts[:verified_level_user]
      @registered_level_resource ||= opts[:registered_level_resource]
      @verified_level_resource ||= opts[:verified_level_resource]
    end

    def test_registered_level
      refute @registered_level_resource.visibility_level_allowed_for? nil
      assert @registered_level_resource.visibility_level_allowed_for? @registered_level_user
      assert @registered_level_resource.visibility_level_allowed_for? @verified_level_user
    end

    def test_verified_level
      refute @verified_level_resource.visibility_level_allowed_for? nil
      refute @verified_level_resource.visibility_level_allowed_for? @registered_level_user
      assert @verified_level_resource.visibility_level_allowed_for? @verified_level_user
    end
  end
end
