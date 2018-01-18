# frozen_string_literal: true

require "test_helper"
require 'support/concerns/gobierto_common/has_visibility_user_levels_test'

module GobiertoParticipation
  class ContributionContainerTest < ActiveSupport::TestCase
    include ::GobiertoCommon::HasVisibilityUserLevelsTest

    def setup
      super
      setup_visibility_user_levels_test(
        registered_level_user: users(:susan),
        verified_level_user: users(:peter),
        registered_level_resource: gobierto_participation_contribution_containers(:children_contributions),
        verified_level_resource: gobierto_participation_contribution_containers(:neighbors_contributions)
      )
    end

    def contribution_container
      @contribution_container ||= gobierto_participation_contribution_containers(:children_contributions)
    end

    def test_valid
      assert contribution_container.valid?
    end

    def test_destroy
      contribution_container.destroy

      assert contribution_container.slug.include?("archived-")
    end
  end
end
