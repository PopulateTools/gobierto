# frozen_string_literal: true

module Publishers
  class GobiertoParticipationProcessActivity
    include Publisher
    self.pub_sub_namespace = "activities/gobierto_participation_processes"
  end
end
