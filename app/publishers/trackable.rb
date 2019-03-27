# frozen_string_literal: true

module Publishers
  class Trackable
    include Publisher

    self.pub_sub_namespace = "trackable"
  end
end
