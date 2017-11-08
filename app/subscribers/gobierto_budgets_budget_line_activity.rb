# frozen_string_literal: true

module Subscribers
  class GobiertoBudgetsBudgetLineActivity < ::Subscribers::Base

    def budgets_forecast_economic_updated(event)
      create_activity_from_event(event, action_name_for('forecast', GobiertoBudgets::EconomicArea))
    end

    def budgets_forecast_functional_updated(event)
      create_activity_from_event(event, action_name_for('forecast', GobiertoBudgets::FunctionalArea))
    end

    def budgets_forecast_custom_updated(event)
      create_activity_from_event(event, action_name_for('forecast', GobiertoBudgets::CustomArea))
    end

    def budgets_execution_economic_updated(event)
      create_activity_from_event(event, action_name_for('execution', GobiertoBudgets::EconomicArea))
    end

    def budgets_execution_functional_updated(event)
      create_activity_from_event(event, action_name_for('execution', GobiertoBudgets::FunctionalArea))
    end

    def budgets_execution_custom_updated(event)
      create_activity_from_event(event, action_name_for('execution', GobiertoBudgets::CustomArea))
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

    def action_name_for(index, area)
      "gobierto_budgets.budgets_#{index}_#{area.area_name}_updated"
    end

  end
end
