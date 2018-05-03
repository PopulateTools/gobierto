module GobiertoCalendars
  module CalendarIntegration
    class AuthError < Error

      def message
        I18n.t "gobierto_calendars.calendar_integration.auth_error.message"
      end

    end
  end
end