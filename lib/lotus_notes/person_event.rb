module LotusNotes
  class PersonEvent

    attr_accessor :external_id, :title, :starts_at, :ends_at, :state, :transparency, :person

    def initialize(person, response_event)
      @external_id  = response_event['id']
      @title        = response_event['summary']
      @transparency = response_event['transparency']
      @state        = public? ? GobiertoPeople::PersonEvent.states[:published] : GobiertoPeople::PersonEvent.states[:pending]
      @person       = person
      set_start_and_end_date(response_event)
    end

    def self.synchronized_attributes
      ['title', 'starts_at', 'ends_at', 'state']
    end

    def hash_version
      as_json.slice(*PersonEvent.synchronized_attributes)
    end

    def sync
      if has_gobierto_event? && gobierto_event_outdated?
        update
      elsif public?
        create
      end
    end

    def gobierto_event
      GobiertoPeople::PersonEvent.find_by_external_id(self.external_id)
    end

    def has_gobierto_event?
      gobierto_event.present?
    end

    def gobierto_event_outdated?
      !has_gobierto_event? || (hash_version != gobierto_event.slice(*PersonEvent.synchronized_attributes))
    end

    def public?
      transparency == 'transparent'
    end

    private

    def create
      GobiertoPeople::PersonEvent.create!(
        external_id: external_id,
        title: title,
        starts_at: starts_at,
        ends_at: ends_at,
        state: state,
        person: person,
        state: state
      )
    end

    def update
      gobierto_event.update_attributes!(
        title: title,
        starts_at: starts_at,
        ends_at: ends_at,
        state: state
      )
    end

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
