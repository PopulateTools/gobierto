# frozen_string_literal: true

module Publishers
  class GobiertoParticipationContributionContainerActivity
    include Publisher
    self.pub_sub_namespace = "activities/gobierto_participation_contribution_containers"
  end
end
