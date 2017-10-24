# frozen_string_literal: true

module Publishers
  class ScopeActivity
    include Publisher
    self.pub_sub_namespace = 'activities/scopes'
  end
end
