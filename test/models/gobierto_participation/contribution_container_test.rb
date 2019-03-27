# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_common/has_visibility_user_levels_test"

module GobiertoParticipation
  class ContributionContainerTest < ActiveSupport::TestCase
    include ::GobiertoCommon::HasVisibilityUserLevelsTest

    def process
      @process ||= gobierto_participation_processes(:bowling_group_very_active)
    end

    def bowling_contributions
      @bowling_contributions ||= gobierto_participation_contribution_containers(:bowling_group_contributions_current)
    end
    alias contribution_container bowling_contributions

    def neighbors_contributions
      @neighbors_contributions ||= gobierto_participation_contribution_containers(:neighbors_contributions)
    end
    alias unpopular_contribution_container neighbors_contributions

    def setup
      super
      setup_visibility_user_levels_test(
        registered_level_user: users(:susan),
        verified_level_user: users(:peter),
        registered_level_resource: gobierto_participation_contribution_containers(:children_contributions),
        verified_level_resource: gobierto_participation_contribution_containers(:neighbors_contributions)
      )
    end

    def test_valid
      assert contribution_container.valid?
    end

    def test_destroy
      contribution_container.destroy

      assert contribution_container.slug.include?("archived-")
    end

    def test_comments_count
      assert_equal 0, unpopular_contribution_container.comments_count

      # susan commented once, reed commented twice
      assert_equal 3, contribution_container.comments_count
    end

    def test_participants_count
      assert_equal 0, unpopular_contribution_container.participants_count

      # susan & peter created contributions, susan & reed commented, peter voted
      assert_equal 3, contribution_container.participants_count
    end

    def test_public?
      assert contribution_container.public?

      process.draft!

      refute contribution_container.public?

      contribution_container.draft!

      refute contribution_container.public?

      process.active!

      refute contribution_container.public?
    end

  end
end
