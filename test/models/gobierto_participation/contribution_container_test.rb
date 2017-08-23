# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ContributionContainerTest < ActiveSupport::TestCase
    def contribution_container
      @contribution_container ||= gobierto_participation_contribution_containers(:children_contributions)
    end

    def test_valid
      assert contribution_container.valid?
    end
  end
end
