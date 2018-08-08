# frozen_string_literal: true

module Publishers
  class GobiertoCommonTermActivity
    include Publisher
    self.pub_sub_namespace = "activities/gobierto_common_terms"
  end
end
