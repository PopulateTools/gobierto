# frozen_string_literal: true

module Publishers
  class GobiertoPlansPlanTypeActivity
    include Publisher
    self.pub_sub_namespace = "activities/gobierto_plans_plan_types"
  end
end
