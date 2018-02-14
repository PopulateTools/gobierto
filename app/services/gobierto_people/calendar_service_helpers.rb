module GobiertoPeople
  module CalendarServiceHelpers

    extend ActiveSupport::Concern

    def log_message(message)
      Rails.logger.info("[SYNC-AGENDAS] #{message}")
    end

    def log_synchronization_start(calendar_identifiers = {})
      log_message("Synchronization of #{calendar_identifiers} has started.")
    end

    def log_synchronization_end(calendar_identifiers = {})
      log_message("Synchronization of '#{calendar_identifiers}' has finished.")
    end

    def log_available_calendars_count(calendars_size)
      log_message("Found #{calendars_size} available calendars for this person.")
    end

    def log_available_events_count(events_count)
      log_message("Found #{events_count} available events for this person.")
    end

    def log_invalid_event(error_messages)
      log_message("Invalid event: #{error_messages}")
    end

    def log_destroy_rule
      log_message("Event destroyed by filter rule")
    end

  end
end