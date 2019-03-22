# frozen_string_literal: true

module Publishers
  class AdminGroupActivity
    include Publisher

    self.pub_sub_namespace = "activities/admin_groups"
  end
end
