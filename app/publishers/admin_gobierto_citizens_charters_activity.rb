# frozen_string_literal: true

module Publishers
  class AdminGobiertoCitizensChartersActivity
    include Publisher

    self.pub_sub_namespace = "activities/admin_gobierto_citizens_charters"
  end
end
