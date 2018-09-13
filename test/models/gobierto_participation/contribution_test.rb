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

    def process
      @process ||= gobierto_participation_processes(:bowling_group_very_active)
    end

    def contribution_container
      @contribution_container ||= gobierto_participation_contribution_containers(:bowling_group_contributions_current)
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

    def test_to_path
      expected_path = "/participacion/p/#{process.slug}/aportaciones/#{contribution_container.slug}##{contribution.slug}"
      assert_equal expected_path, contribution.to_path
    end

    def test_to_url
      expected_url = "http://madrid.gobierto.test/participacion/p/#{process.slug}/aportaciones/#{contribution_container.slug}##{contribution.slug}"
      assert_equal expected_url, contribution.to_url
    end

  end
end
