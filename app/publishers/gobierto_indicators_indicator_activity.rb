# frozen_string_literal: true

module Publishers
  class GobiertoIndicatorsIndicatorActivity
    include Publisher
    self.pub_sub_namespace = "activities/gobierto_indicators_indicators"
  end
end
