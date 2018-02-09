# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ContributionTest < ActiveSupport::TestCase

    def reed
      @reed ||= users(:reed)
    end

    def susan
      @susan ||= users(:susan)
    end

    def peter
      @peter ||= users(:peter)
    end

    def contribution
      @contribution ||= gobierto_participation_contributions(:bad_losers_contribution)
    end

    def unpopular_contribution
      @unpopular_contribution ||= gobierto_participation_contributions(:bad_losers_unpopular_contribution)
    end

    def test_valid
      assert contribution.valid?
    end

    def test_participants_ids
      assert unpopular_contribution.participants_ids.empty?

      # reed & susan are comment authors, peter voted
      assert array_match([reed.id, susan.id, peter.id], contribution.participants_ids)

      # force susan to appear twice to make sure .participants_ids is removing duplicated ids
      contribution.votes.first.stubs(:map).returns([susan.id, susan.id])
      assert array_match([reed.id, susan.id, peter.id], contribution.participants_ids)
    end

    def test_participants_count
      assert_equal 0, unpopular_contribution.participants_count

      # reed & susan are comment authors, peter voted
      assert_equal 3, contribution.participants_count
    end

  end
end
