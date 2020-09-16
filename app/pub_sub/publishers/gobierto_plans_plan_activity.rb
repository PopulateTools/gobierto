# frozen_string_literal: true

module Publishers
  class GobiertoPlansPlanActivity
    include Publisher
    self.pub_sub_namespace = 'activities/gobierto_plans_plans'
  end
end
