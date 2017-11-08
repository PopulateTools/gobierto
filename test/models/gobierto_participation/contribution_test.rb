# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ContributionTest < ActiveSupport::TestCase
    def contribution
      @contribution ||= gobierto_participation_contributions(:cinema)
    end

    def test_valid
      assert contribution.valid?
    end
  end
end
