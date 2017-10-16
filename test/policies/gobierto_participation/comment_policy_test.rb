# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class CommentPolicyTest < ActiveSupport::TestCase
    def user
      @user ||= users(:dennis)
    end

    def commmentable
      @commmentable ||= gobierto_participation_comments(:cinema_reed_comment)
    end

    def test_create?
      assert CommentPolicy.new(user).create?
      refute CommentPolicy.new(nil).create?
    end
  end
end
