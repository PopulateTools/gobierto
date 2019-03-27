# frozen_string_literal: true

module GobiertoCommon
  module ActiveNotifier
    class Daily
      extend GobiertoBudgetConsultations::ActiveNotifier::Events

      EVENTS_TO_TRIGGER = %w(
        notify_consultations_opening_today
        notify_consultations_closing_today
        notify_consultations_about_to_close
      ).freeze

      def self.call
        EVENTS_TO_TRIGGER.each do |event_name|
          send(event_name) if respond_to?(event_name)
        end
      end
    end
  end
end
