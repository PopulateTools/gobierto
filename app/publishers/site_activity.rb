# frozen_string_literal: true

module Publishers
  class SiteActivity
    include Publisher

    self.pub_sub_namespace = "activities/sites"
  end
end
