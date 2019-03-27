# frozen_string_literal: true

module Publishers
  class CensusActivity
    include Publisher

    self.pub_sub_namespace = "activities/census"
  end
end
