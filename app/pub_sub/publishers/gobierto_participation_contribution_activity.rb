# frozen_string_literal: true

module Publishers
  class GobiertoParticipationContributionActivity
    include Publisher
    self.pub_sub_namespace = "activities/gobierto_participation_contribution"
  end
end
