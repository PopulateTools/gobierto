# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class VoteTest < ActiveSupport::TestCase
    def vote
      @vote ||= gobierto_participation_votes(:activities_susan_vote)
    end

    def test_valid
      assert vote.valid?
    end
  end
end
