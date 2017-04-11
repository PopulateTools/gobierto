module GobiertoPeople
  class AgendasIntegration

    def self.sync_all_agendas
      Site.with_agendas_integration_enabled.each do |site|
        site.people.with_synchronized_agenda.each { |person| sync_person_events(person) }
      end
    end

    private

    def self.sync_person_events(person)
      received_events = LotusNotes::Api.get_person_events person.calendar_endpoint

      received_events.each do |event_hash|
        event = LotusNotes::PersonEvent.new(person, event_hash)
        event.sync
      end

      mark_deleted_future_events_as_drafts(person, received_events)
    end

    def self.mark_deleted_future_events_as_drafts(person, received_events)
      person.events.synchronized_future_events.each do |future_event|
        unless received_events.map { |event| event['id'] }.include?(future_event.external_id)
          future_event.update_attribute(:state, PersonEvent.states[:pending])
        end
      end
    end

  end
end
