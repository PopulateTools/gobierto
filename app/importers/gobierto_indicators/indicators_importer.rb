# frozen_string_literal: true

module GobiertoIndicators
  class IndicatorsImporter
    def initialize(name, site, response, year = nil)
      @name = name
      @site = site
      @response = response
      @year = year
    end

    def import!
      import_indicator
      reset_cache
      publish_event
    end

    private

    attr_reader :name, :site, :response, :year

    def import_indicator
      @indicator = GobiertoIndicators::Indicator.find_or_create_by(name: name,
                                                                   site: site,
                                                                   year: year)
      @indicator.indicator_response = @response
      @indicator.save
    end

    def reset_cache
      Rails.cache.clear
    end

    def publish_event
      action = "indicator_updated"

      Publishers::GobiertoIndicatorsIndicatorActivity.broadcast_event(action, {
        action: action,
        site_id: site.id,
        indicator_id: @indicator.id
      })
    end
  end
end
