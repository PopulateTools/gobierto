# frozen_string_literal: true

module Publishers
  class AdminActivity
    include Publisher

    self.pub_sub_namespace = "activities/admins"
  end
end
