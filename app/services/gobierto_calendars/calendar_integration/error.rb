# frozen_string_literal: true

module GobiertoCalendars
  module CalendarIntegration
    class Error < StandardError

      def initialize(message = nil)
        super(message || default_message)
      end

      private

      def default_message
        I18n.t "gobierto_calendars.calendar_integration.error.message"
      end

    end
  end
end
