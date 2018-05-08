# frozen_string_literal: true

module GobiertoCalendars
  module CalendarIntegration
    class Error < StandardError

      def message
        I18n.t "gobierto_calendars.calendar_integration.error.message"
      end

    end
  end
end