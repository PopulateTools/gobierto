# frozen_string_literal: true

module Publishers
  class AdminGobiertoInvestmentsActivity
    include Publisher

    self.pub_sub_namespace = "activities/admin_gobierto_investments"
  end
end
