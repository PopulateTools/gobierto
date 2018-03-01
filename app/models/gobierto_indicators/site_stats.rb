# frozen_string_literal: true

module GobiertoIndicators
  class SiteStats
    def initialize(options)
      @site = options.fetch :site
      @indicator = options.fetch :indicator
    end

    def indicator_updated_at
      activity_updated_at = @site.activities.where(subject: @indicator)
                                 .order(created_at: :asc)
                                 .pluck(:created_at)
                                 .last

      if activity_updated_at
        [@indicator.updated_at, activity_updated_at].max
      else
        @indicator.updated_at
      end
    end
  end
end
