module IbmNotes
  class PersonEvent

    attr_accessor :external_id, :title, :starts_at, :ends_at, :state, :person, :location

    def initialize(person, response_event)
      set_external_id(response_event)
      @title        = response_event['summary']
      @state        = 'published'
      @person       = person
      @location     = response_event['location'] if response_event['location'].present?
      set_start_and_end_date(response_event)
    end

    def self.synchronized_attributes
      ['title', 'starts_at', 'ends_at', 'state']
    end

    def gobierto_event
      person.events.find_by_external_id(self.external_id)
    end

    def has_gobierto_event?
      gobierto_event.present?
    end

    def first_synchronization?
      !has_gobierto_event?
    end

    def gobierto_event_outdated?
      has_gobierto_event? && self.class.synchronized_attributes.any? { |attr_name| self.send(attr_name.to_sym) != gobierto_event.send(attr_name.to_sym) }
    end

    def gobierto_event_location_outdated?
      has_gobierto_event? && (
        location_has_been_added? ||
        location_has_been_removed? ||
        (gobierto_event.locations.first.present? && location != gobierto_event.locations.first.name)
      )
    end

    def location_previously_synced?
      location.present? && gobierto_event.locations.any?
    end

    def location_has_been_added?
      location.present? && gobierto_event.locations.empty?
    end

    def location_has_been_removed?
      location.blank? && gobierto_event.locations.any?
    end

    private

    def set_external_id(event)
      if event['recurrenceId'].present?
        @external_id = "#{event['id']}/#{event['recurrenceId']}"
      else
        @external_id = event['id']
      end
    end

    def set_start_and_end_date(event)
      if event['start']['tzid'].present? && event['start']['tzid'] == 'Romance Standard Time'
        @starts_at = ActiveSupport::TimeZone['Madrid'].parse("#{event['start']['date']} #{event['start']['time']}").utc
        @ends_at   = ActiveSupport::TimeZone['Madrid'].parse("#{event['end']['date']} #{event['end']['time']}").utc || starts_at + 1.hour
      else # assume UTC
        @starts_at = parse_date event['start']
        @ends_at   = parse_date(event['end']) || starts_at + 1.hour
      end
    end

    def parse_date(date)
      unless date.nil?
        d = Time.parse("#{date['date']} #{date['time']}")
        Time.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
      end
    end

  end
end
