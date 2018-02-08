# frozen_string_literal: true

module Publishers
  class IssueActivity
    include Publisher
    self.pub_sub_namespace = "activities/issues"
  end
end
