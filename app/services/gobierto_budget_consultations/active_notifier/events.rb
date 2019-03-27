# frozen_string_literal: true

module GobiertoBudgetConsultations
  module ActiveNotifier
    module Events
      def notify_consultations_opening_today
        event_name = "opened"

        Consultation.opening_today.find_each do |consultation|
          event_payload = { gid: consultation.to_gid, site_id: consultation.site_id }
          Publishers::Trackable.broadcast_event(event_name, event_payload)
        end
      end

      def notify_consultations_closing_today
        event_name = "closed"

        Consultation.closing_today.find_each do |consultation|
          event_payload = { gid: consultation.to_gid, site_id: consultation.site_id }
          Publishers::Trackable.broadcast_event(event_name, event_payload)
        end
      end

      def notify_consultations_about_to_close
        event_name = "about_to_close"

        Consultation.about_to_close.find_each do |consultation|
          event_payload = { gid: consultation.to_gid, site_id: consultation.site_id }
          Publishers::Trackable.broadcast_event(event_name, event_payload)
        end
      end
    end
  end
end
