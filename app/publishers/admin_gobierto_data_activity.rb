# frozen_string_literal: true

module Publishers
  class AdminGobiertoDataActivity
    include Publisher

    self.pub_sub_namespace = "activities/admin_gobierto_data"
  end
end
