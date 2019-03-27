# frozen_string_literal: true

module Publishers
  class GobiertoParticipationPollActivity
    include Publisher
    self.pub_sub_namespace = "activities/gobierto_participation_polls"
  end
end
