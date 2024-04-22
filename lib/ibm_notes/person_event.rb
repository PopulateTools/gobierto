# frozen_string_literal: true

module IbmNotes
  class PersonEvent
    attr_accessor :id, :title, :description, :starts_at, :ends_at, :person, :location, :attendees

    MADRID_TIMEZONES = [
      "Romance Standard Time",
      "Western/Central Europe",
      "GMT+1 Standard Time",
      "Europe/Madrid",
      "Central Europe Standard Time",
      "Fus horari desconegut (1) Standard Time",
      "Huso horario desconocido (1) Standard Time",
      "W. Europe Standard Time",
      "Unknown1 Standard Time",
      "Unknown Time Zone (1) Standard Time"
    ].freeze

    UTC_TIMEZONES = [ "UTC", "GMT Standard Time" ].freeze

    def initialize(person, response_event)
      @id = set_id(response_event)
      @title = response_event["summary"]
      @description = response_event["description"] if response_event["description"].present?
      @person = person
      @location = response_event["location"] if response_event["location"].present?
      @attendees = set_attendees(response_event)
      set_start_and_end_date(response_event)
    end

    private

    def set_id(event)
      if event["recurrenceId"].present?
        "#{event["id"]}/#{event["recurrenceId"]}"
      else
        event["id"]
      end
    end

    def set_start_and_end_date(event)
      if time_zone = event["start"]["tzid"]
        time_zone = if MADRID_TIMEZONES.include?(time_zone)
          ActiveSupport::TimeZone["Madrid"]
        elsif UTC_TIMEZONES.include?(time_zone)
          ActiveSupport::TimeZone["UTC"]
        else
          tz = ActiveSupport::TimeZone[time_zone]
          if tz.nil?
            Appsignal.send_error(Exception.new("[GobiertoCalendars] Unknown IBM Notes time zone #{time_zone}"))
            nil
          end
        end
      end

      if time_zone
        @starts_at = time_zone.parse("#{event["start"]["date"]} #{event["start"]["time"]}").utc
        @ends_at = time_zone.parse("#{event["end"]["date"]} #{event["end"]["time"]}").utc || starts_at + 1.hour
      else # assume UTC
        @starts_at = parse_date event["start"]
        @ends_at = parse_date(event["end"]) || starts_at + 1.hour
      end
    end

    def parse_date(date)
      unless date.nil?
        d = Time.parse("#{date["date"]} #{date["time"]}")
        Time.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
      end
    end

    def set_attendees(event)
      if event["attendees"].present?
        event["attendees"].map do |attendee|
          next unless (attendee["status"] == "accepted" || attendee["role"] == "req-participant") && attendee["displayName"].present?
          {
            name: attendee["displayName"].split("/").first,
            email: attendee["email"]
          }
        end.compact
      else
        []
      end
    end
  end
end
