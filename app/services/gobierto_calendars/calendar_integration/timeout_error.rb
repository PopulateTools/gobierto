module GobiertoCalendars
  module CalendarIntegration
    class TimeoutError < Error

      def message
        I18n.t "gobierto_calendars.calendar_integration.timeout_error.message"
      end

    end
  end
end