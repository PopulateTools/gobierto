# frozen_string_literal: true

module GobiertoPlans
  class SiteStats
    def initialize(options)
      @site = options.fetch :site
      @plan = options.fetch :plan
    end

    def plan_updated_at
      activity_updated_at = @site.activities.where(subject: @plan)
                                 .order(created_at: :asc)
                                 .pluck(:created_at)
                                 .last

      if activity_updated_at
        [@plan.updated_at, activity_updated_at].max.to_date
      else
        @plan.updated_at.to_date
      end
    end
  end
end
