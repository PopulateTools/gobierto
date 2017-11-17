# frozen_string_literal: true

module Subscribers
  class GobiertoBudgetsBudgetLineActivity < ::Subscribers::Base

    def budgets_updated(event)
      create_activity_from_event(event, "gobierto_budgets.budgets_updated")
    end

    private

    def create_activity_from_event(event, action)
      site = Site.find(event.payload[:site_id])

      Activity.create!(
        action: action,
        subject: site,
        subject_ip: '127.0.0.1',
        admin_activity: false,
        site_id: site.id
      )
    end
  end
end
