# frozen_string_literal: true

module GobiertoPlans
  class SiteStats
    def initialize(options)
      @site = options.fetch :site
      @plan = options.fetch :plan
    end

    def plan_updated_at
      @site.activities.where(subject: @plan)
           .order(created_at: :asc)
           .pluck(:created_at)
           .last
    end
  end
end
