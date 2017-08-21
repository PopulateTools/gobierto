# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ContributionContainerTest < ActiveSupport::TestCase
    def contributor_container
      @contributor_container ||= gobierto_participation_contributor_containers(:children_contributions)
    end

    def test_valid
      assert contributor_container.valid?
    end
  end
end
