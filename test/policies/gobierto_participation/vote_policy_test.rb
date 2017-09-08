# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class VotePolicyTest < ActiveSupport::TestCase
    def user
      @user ||= users(:dennis)
    end

    def votable
      @votable ||= gobierto_participation_comments(:cinema_reed_comment)
    end

    def test_create?
      assert VotePolicy.new(user).create?
      refute VotePolicy.new(nil).create?
    end
  end
end
