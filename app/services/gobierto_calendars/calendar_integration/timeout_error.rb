# frozen_string_literal: true

module GobiertoCalendars
  module CalendarIntegration
    class TimeoutError < Error

      private

      def default_message
        I18n.t "gobierto_calendars.calendar_integration.timeout_error.message"
      end

    end
  end
end
