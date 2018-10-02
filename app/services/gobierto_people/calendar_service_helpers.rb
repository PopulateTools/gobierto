# frozen_string_literal: true

require "#{Rails.root}/lib/utils/string_obfuscator"

module GobiertoPeople
  module CalendarServiceHelpers

    extend ActiveSupport::Concern

    def log_message(message)
      Rails.logger.info("[SYNC-AGENDAS]#{integration_log_preffix} #{message}")
    end

    def log_synchronization_start(calendar_identifiers = {})
      log_message("Synchronization of #{calendar_identifiers} has started.")
    end

    def log_synchronization_end(calendar_identifiers = {})
      log_message("Synchronization of #{calendar_identifiers} has finished.")
    end

    def log_available_calendars_count(calendars_size)
      log_message("Found #{calendars_size} available calendars for this person.")
    end

    def log_available_events_count(events_count)
      log_message("Found #{events_count} available events for this person.")
    end

    def log_saved_event(event_form)
      log_message("Saved: #{event_form.title} on #{event_form.starts_at}")
    end

    def log_invalid_event(event_form)
      log_message("Invalid: #{event_form.errors.messages}")
    end

    def log_destroy_rule(title = nil)
      msg = "Destroyed by filter rule"
      msg += ": #{::StringObfuscator.obfuscate(title, percent: 50)}" if title
      log_message msg
    end

  end
end
