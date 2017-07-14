module Publishers
  class GobiertoBudgetsBudgetLineActivity
    include Publisher

    self.pub_sub_namespace = 'activities/gobierto_budgets_budget_line'
  end
end
