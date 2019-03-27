# frozen_string_literal: true

module Publishers
  class GobiertoCommonCollectionActivity
    include Publisher
    self.pub_sub_namespace = "activities/gobierto_common_collections"
  end
end
