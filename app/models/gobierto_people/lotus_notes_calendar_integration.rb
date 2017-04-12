module GobiertoPeople
  class LotusNotesCalendarIntegration

    def self.sync_person_events(person)
      received_events = LotusNotes::Api.get_person_events(request_params(person))

      received_events.each do |event_hash|
        event = LotusNotes::PersonEvent.new(person, event_hash)
        event.sync
      end

      received_events_ids = received_events.map { |event| event['id'] }

      person.events.synchronized_future_events.each do |future_event|
        unless received_events_ids.include?(future_event.external_id)
          future_event.pending!
        end
      end
    end

    private

    def self.request_params(person)
      {
        endpoint: get_calendar_endpoint(person),
        username: person.site.gobierto_people_settings.find_by_key('LOTUS_ENDPOINT_USR').value,
        password: person.site.gobierto_people_settings.find_by_key('LOTUS_ENDPOINT_PWD').value
      }
    end

    def self.get_calendar_endpoint(person)
      person_calendar_configuration = PersonLotusNotesCalendarConfiguration.find_by_person_id(person.id)
      person_calendar_configuration.endpoint
    end

  end
end
