module LotusNotes
  class PersonEvent

    attr_accessor :external_id, :title, :starts_at, :ends_at, :state, :transparency, :person

    def initialize(person, response_event)
      @external_id  = response_event['id']
      @title        = response_event['summary']
      @transparency = response_event['transparency']
      @state        = public? ? 'published' : 'pending'
      @person       = person
      set_start_and_end_date(response_event)
    end

    def self.synchronized_attributes
      ['title', 'starts_at', 'ends_at', 'state']
    end

    def gobierto_event
      GobiertoPeople::PersonEvent.find_by_external_id(self.external_id)
    end

    def has_gobierto_event?
      gobierto_event.present?
    end

    def gobierto_event_outdated?
      has_gobierto_event? && (to_hash != gobierto_event.attributes.slice(*PersonEvent.synchronized_attributes))
    end

    def public?
      transparency == 'transparent'
    end

    def to_hash
      hash = {}
      PersonEvent.synchronized_attributes.each do |attribute|
        hash[attribute] = instance_variable_get("@#{attribute}")
      end
      hash
    end

    private

    def set_start_and_end_date(event)
      @starts_at = parse_date event['start']
      @ends_at   = parse_date(event['end']) || starts_at + 1.hour
    end

    def parse_date(date)
      unless date.nil?
        d = Time.parse("#{date['date']} #{date['time']}")
        Time.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
      end
    end

  end
end
