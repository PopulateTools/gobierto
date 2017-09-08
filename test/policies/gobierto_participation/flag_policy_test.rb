# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class FlagPolicyTest < ActiveSupport::TestCase
    def user
      @user ||= users(:dennis)
    end

    def flaggable
      @flaggable ||= gobierto_participation_comments(:cinema_reed_comment)
    end

    def test_create?
      assert FlagPolicy.new(user).create?
      refute FlagPolicy.new(nil).create?
    end
  end
end
