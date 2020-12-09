# frozen_string_literal: true

module Subscribers
  class GobiertoIndicatorsIndicatorActivity < ::Subscribers::Base
    def indicator_updated(event)
      create_activity_from_event(event, "gobierto_indicators.indicator_updated")
    end

    private

    def create_activity_from_event(event, action)
      site = Site.find(event.payload[:site_id])
      indicator = GobiertoIndicators::Indicator.find(event.payload[:indicator_id])

      Activity.create!(
        action: action,
        subject: indicator,
        subject_ip: "127.0.0.1",
        admin_activity: false,
        site_id: site.id
      )
    end
  end
end
