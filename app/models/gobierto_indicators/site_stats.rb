# frozen_string_literal: true

module GobiertoIndicators
  class SiteStats
    def initialize(options)
      @site = options.fetch :site
      @indicator = options.fetch :indicator
    end

    def indicator_updated_at
      activity_updated_at = @site.activities.where(subject: @indicator)
                                 .order(created_at: :desc)
                                 .limit(1)
                                 .pluck(:created_at)
                                 .first

      if activity_updated_at
        [@indicator.updated_at, activity_updated_at].max.to_date
      else
        @indicator.updated_at.to_date
      end
    end
  end
end
