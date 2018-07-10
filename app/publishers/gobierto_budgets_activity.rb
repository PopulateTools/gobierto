# frozen_string_literal: true

module Publishers
  class GobiertoBudgetsActivity
    include Publisher

    self.pub_sub_namespace = 'activities/gobierto_budgets'
  end
end
