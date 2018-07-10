# frozen_string_literal: true

module GobiertoCalendars
  module CalendarIntegration
    class AuthError < Error

      private

      def default_message
        I18n.t "gobierto_calendars.calendar_integration.auth_error.message"
      end

    end
  end
end
