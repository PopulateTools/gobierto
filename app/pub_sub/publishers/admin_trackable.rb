# frozen_string_literal: true

module Publishers
  class AdminTrackable
    include Publisher

    self.pub_sub_namespace = "admin_trackable"
  end
end
